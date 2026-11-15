package com.transport.api.controller;

import com.transport.api.dto.PaiementRequest;
import com.transport.api.model.Paiement;
import com.transport.api.model.Reservation;
import com.transport.api.model.User;
import com.transport.api.repository.ReservationRepository;
import com.transport.api.repository.UserRepository;
import com.transport.api.service.PaiementService;

import jakarta.validation.Valid;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/paiements")
public class PaiementController {

    @Autowired
    private PaiementService paiementService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ReservationRepository reservationRepository;

    // === UTILITAIRES SÉCURITÉ (identiques dans chaque Controller protégé) ===

    private User getUserConnecte() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String telephone = authentication.getName();
        return userRepository.findByTelephone(telephone)
                .orElseThrow(() -> new RuntimeException("Utilisateur connecté introuvable"));
    }

    private boolean estAdmin(User user) {
        return user.getRole().equals("admin_agence") || user.getRole().equals("super_admin");
    }

    // === LECTURE (GET) ===

    // Liste complète — réservée aux admins (comptabilité agence/super admin)
    @GetMapping
    public ResponseEntity<?> getAllPaiements() {
        User userConnecte = getUserConnecte();
        if (!estAdmin(userConnecte)) {
            return ResponseEntity.status(403).body(Map.of("error", "Accès réservé aux administrateurs"));
        }
        return ResponseEntity.ok(paiementService.getAllPaiements());
    }

    // Détail d'un paiement — IDOR protégée via la réservation liée

    @GetMapping("/{id}")
    public ResponseEntity<?> getPaiementById(@PathVariable Long id) {
        User userConnecte = getUserConnecte();
        return paiementService.getPaiementById(id)
            .map(paiement -> {
                List<Reservation> reservations = reservationRepository.findByGroupeId(paiement.getGroupeId());
                boolean appartientAuUser = !reservations.isEmpty() && reservations.stream()
                        .allMatch(r -> r.getUser().getId().equals(userConnecte.getId()));

                if (!appartientAuUser && !estAdmin(userConnecte)) {
                    return ResponseEntity.status(403).body(Map.of("error", "Ce paiement ne vous appartient pas"));
                }
                return ResponseEntity.ok(paiement);
            })
            .orElse(ResponseEntity.notFound().build());
    }

    // Paiement lié à une réservation précise — IDOR protégé

    // Paiement lié à un groupe de réservations précis — IDOR protégé
    @GetMapping("/groupe/{groupeId}")
    public ResponseEntity<?> getPaiementByGroupe(@PathVariable String groupeId) {
        User userConnecte = getUserConnecte();

    List<Reservation> reservations = reservationRepository.findByGroupeId(groupeId);
        if (reservations.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

    boolean appartientAuUser = reservations.stream()
            .allMatch(r -> r.getUser().getId().equals(userConnecte.getId()));

    if (!appartientAuUser && !estAdmin(userConnecte)) {
        return ResponseEntity.status(403).body(Map.of("error", "Ces réservations ne vous appartiennent pas"));
        }

        return paiementService.getPaiementByGroupe(groupeId)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }
  

    // === ÉCRITURE (POST/PUT/DELETE) ===

    // Création — vérifie que la réservation appartient au user connecté (anti-paiement pour autrui)
    @PostMapping
    
    public ResponseEntity<?> createPaiement(@Valid @RequestBody PaiementRequest request) {
        User userConnecte = getUserConnecte();

        List<Reservation> reservations = reservationRepository.findByGroupeId(request.getGroupeId());
        if (reservations.isEmpty()) {
         return ResponseEntity.badRequest().body(Map.of("error", "Groupe de réservation introuvable"));
        }

        boolean appartientAuUser = reservations.stream()
            .allMatch(r -> r.getUser().getId().equals(userConnecte.getId()));

        if (!appartientAuUser) {
            return ResponseEntity.status(403).body(Map.of("error", "Ces réservations ne vous appartiennent pas"));
        }

        return ResponseEntity.ok(paiementService.createPaiement(request));
    }

    // Confirmer le paiement — usage interne (futur webhook Lumicash)
    @PutMapping("/{id}/confirmer")
    public ResponseEntity<?> confirmerPaiement(@PathVariable Long id) {
        return ResponseEntity.ok(paiementService.confirmerPaiement(id));
    }

    // Modification — usage interne (ex: confirmation via webhook Lumicash plus tard)
    // TODO futur : remplacer cet endpoint manuel par un vrai webhook opérateur (Lumicash/EcoCash/etc.)
    

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletePaiement(@PathVariable Long id) {
        paiementService.deletePaiement(id);
        return ResponseEntity.ok().build();
    }
}