package com.transport.api.controller;

import com.transport.api.dto.FavoriRequest;
import com.transport.api.model.Favori;
import com.transport.api.model.User;
import com.transport.api.repository.FavoriRepository;
import com.transport.api.repository.UserRepository;
import com.transport.api.service.FavoriService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import java.util.Map;

@RestController
@RequestMapping("/api/favoris")
public class FavoriController {

    @Autowired
    private FavoriService favoriService;

    @Autowired
    private FavoriRepository favoriRepository;

    @Autowired
    private UserRepository userRepository;

    private User getUserConnecte() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String telephone = authentication.getName();
        return userRepository.findByTelephone(telephone)
                .orElseThrow(() -> new RuntimeException("Utilisateur connecté introuvable"));
    }

    // Ajouter un favori — pour l'utilisateur connecté uniquement
    @PostMapping
    public ResponseEntity<?> ajouter(@Valid @RequestBody FavoriRequest request) {
        User userConnecte = getUserConnecte();
        try {
            Favori favori = favoriService.ajouter(userConnecte.getId(), request);
            return ResponseEntity.ok(favori);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    // Liste des favoris — IDOR protégé
    @GetMapping("/user/{userId}")
    public ResponseEntity<?> getByUser(@PathVariable Long userId) {
        User userConnecte = getUserConnecte();
        boolean estAdmin = userConnecte.getRole().equals("admin_agence") || userConnecte.getRole().equals("super_admin");

        if (!userConnecte.getId().equals(userId) && !estAdmin) {
            return ResponseEntity.status(403).body(Map.of("error", "Vous ne pouvez consulter que vos propres favoris"));
        }
        return ResponseEntity.ok(favoriService.getFavorisByUser(userId));
    }

    // Supprimer un favori — IDOR protégé
    @DeleteMapping("/{id}")
    public ResponseEntity<?> supprimer(@PathVariable Long id) {
        User userConnecte = getUserConnecte();

        return favoriRepository.findById(id)
                .map(favori -> {
                    if (!favori.getUser().getId().equals(userConnecte.getId())) {
                        return ResponseEntity.status(403).body(Map.of("error", "Ce favori ne vous appartient pas"));
                    }
                    favoriService.supprimer(id);
                    return ResponseEntity.ok(Map.of("message", "Favori supprimé"));
                })
                .orElse(ResponseEntity.notFound().build());
    }
}
