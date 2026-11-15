package com.transport.api.controller;

import com.transport.api.dto.ReservationRequest;
import com.transport.api.model.Reservation;
import com.transport.api.model.User;
import com.transport.api.repository.ReservationRepository;
import com.transport.api.repository.UserRepository;
import com.transport.api.service.ReservationService;

import jakarta.validation.Valid;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/reservations")
public class ReservationController {

    @Autowired
    private ReservationService reservationService;

    @Autowired
    private UserRepository userRepository;

    @Autowired 
    private  ReservationRepository reservationRepository;

    // === UTILITAIRES SÉCURITÉ (identiques dans chaque Controller protégé) ===

    // Récupère le user connecté à partir du token JWT
    private User getUserConnecte() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String telephone = authentication.getName();
        return userRepository.findByTelephone(telephone)
                .orElseThrow(() -> new RuntimeException("Utilisateur connecté introuvable"));
    }

    // Vérifie si le user a un rôle admin (agence ou super admin)
    private boolean estAdmin(User user) {
        return user.getRole().equals("admin_agence") || user.getRole().equals("super_admin");
    }

    // === LECTURE (GET) ===

    // Liste complète — réservée aux admins (dashboard agence/super admin)
    @GetMapping
    public ResponseEntity<?> getAllReservations() {
        User userConnecte = getUserConnecte();
        if (!estAdmin(userConnecte)) {
            return ResponseEntity.status(403).body(Map.of("error", "Accès réservé aux administrateurs"));
        }
        return ResponseEntity.ok(reservationService.getAllReservations());
    }

    // Détail d'une réservation — IDOR protégé : uniquement le propriétaire ou un admin
    @GetMapping("/{id}")
    public ResponseEntity<?> getReservationById(@PathVariable Long id) {
        User userConnecte = getUserConnecte();

        return reservationService.getReservationById(id)
                .map(reservation -> {
                    if (!reservation.getUser().getId().equals(userConnecte.getId()) && !estAdmin(userConnecte)) {
                        return ResponseEntity.status(403).body(Map.of("error", "Cette réservation ne vous appartient pas"));
                    }
                    return ResponseEntity.ok(reservation);
                })
                .orElse(ResponseEntity.notFound().build());
    }

    // "Mes réservations" côté app Client — IDOR protégé
    @GetMapping("/user/{userId}")
    public ResponseEntity<?> getReservationsByUser(@PathVariable Long userId) {
        User userConnecte = getUserConnecte();

        if (!userConnecte.getId().equals(userId) && !estAdmin(userConnecte)) {
            return ResponseEntity.status(403).body(Map.of("error", "Vous ne pouvez consulter que vos propres réservations"));
        }

        return ResponseEntity.ok(reservationService.getReservationsByUser(userId));
    }

    // Liste des passagers d'un trajet — usage embarquement, réservé aux admins/chauffeurs
    @GetMapping("/trajet/{trajetId}")
    public ResponseEntity<?> getReservationsByTrajet(@PathVariable Long trajetId) {
        User userConnecte = getUserConnecte();
        if (!estAdmin(userConnecte)) {
            return ResponseEntity.status(403).body(Map.of("error", "Accès réservé aux administrateurs"));
        }
        return ResponseEntity.ok(reservationService.getReservationsByTrajet(trajetId));
    }

    // === ÉCRITURE (POST/PUT/DELETE) ===

    // Création — userId toujours extrait du token, jamais du client (anti-usurpation)
    @PostMapping
    public List<Reservation> createReservation(@Valid @RequestBody ReservationRequest request) {
        User userConnecte = getUserConnecte();
        return reservationService.createReservation(userConnecte.getId(), request);
    }

    // Modification — usage interne (confirmer/annuler), pas encore restreint par rôle ici
    // TODO futur : restreindre updateReservation aux admins ou au propriétaire selon le champ modifié
    @PutMapping("/{id}")
    public ResponseEntity<Reservation> updateReservation(@PathVariable Long id, @RequestBody Reservation reservation) {
        try {
            return ResponseEntity.ok(reservationService.updateReservation(id, reservation));
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteReservation(@PathVariable Long id) {
        reservationService.deleteReservation(id);
        return ResponseEntity.ok().build();
    }



    // Récupération d'un billet via son QR code — pour vérification par un contrôleur
    @GetMapping("/qr/{qrCode}")
    public ResponseEntity<?> getByQrCode(@PathVariable String qrCode) {
        User userConnecte = getUserConnecte();

        return reservationRepository.findByQrCode(qrCode)
            .map(reservation -> {
                boolean estProprietaire = reservation.getUser().getId().equals(userConnecte.getId());
                boolean estStaff = userConnecte.getRole().equals("admin_agence")
                    || userConnecte.getRole().equals("chauffeur")
                    || userConnecte.getRole().equals("super_admin");

            if (!estProprietaire && !estStaff) {
                return ResponseEntity.status(403).body(Map.of("error", "Accès non autorisé à ce billet"));
            }
            return ResponseEntity.ok(reservation);
        })
        .orElse(ResponseEntity.status(404).body(Map.of("error", "Billet introuvable ou invalide")));
    }
}