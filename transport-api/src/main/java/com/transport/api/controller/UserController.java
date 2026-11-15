package com.transport.api.controller;

import com.transport.api.dto.ChangeContactRequest;
import com.transport.api.dto.ConfirmCodeRequest;
import com.transport.api.model.User;
import com.transport.api.repository.UserRepository;
import com.transport.api.service.UserService;

import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;
import java.util.Map;


@RestController
@RequestMapping("/api/users")
public class UserController {

    @Autowired
    private UserService userService;

    @Autowired
    private UserRepository userRepository;

    @Autowired 
    private PasswordEncoder passwordEncoder;

    // Récupère le user actuellement connecté (via son token)
    private User getUserConnecte() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String telephone = authentication.getName();
        return userRepository.findByTelephone(telephone)
                .orElseThrow(() -> new RuntimeException("Utilisateur connecté introuvable"));
    }

    private boolean estAdmin(User user) {
        return user.getRole().equals("admin_agence") || user.getRole().equals("super_admin");
    }

    // GET — Liste complète réservée aux admins
    @GetMapping
    public ResponseEntity<?> getAllUsers() {
        User userConnecte = getUserConnecte();
        if (!estAdmin(userConnecte)) {
            return ResponseEntity.status(403).body(Map.of("error", "Accès réservé aux administrateurs"));
        }
        return ResponseEntity.ok(userService.getAllUsers());
    }

    // GET — Un user ne peut voirr que SA PROPRE fiche, sauf s'il est admin
    @GetMapping("/{id}")
    public ResponseEntity<?> getUserById(@PathVariable Long id) {
        User userConnecte = getUserConnecte();

        if (!userConnecte.getId().equals(id) && !estAdmin(userConnecte)) {
            return ResponseEntity.status(403).body(Map.of("error", "Vous ne pouvez consulter que votre propre profil"));
        }

        return userService.getUserById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public User createUser(@RequestBody User user) {
        return userService.createUser(user);
    }

    // PUT — Un user ne peut modifier que SON PROPRE profil
    @PutMapping("/{id}")
    public ResponseEntity<?> updateUser(@PathVariable Long id, @RequestBody User user) {
        User userConnecte = getUserConnecte();

        if (!userConnecte.getId().equals(id) && !estAdmin(userConnecte)) {
            return ResponseEntity.status(403).body(Map.of("error", "Vous ne pouvez modifier que votre propre profil"));
        }

        try {
            return ResponseEntity.ok(userService.updateUser(id, user));
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }

    // DELETE — déjà réservé à SUPER_ADMIN via SecurityConfig
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable Long id) {
        userService.deleteUser(id);
        return ResponseEntity.ok().build();
    }

    //Le user peut supprimer son compte, je veux adapter la règle de google play depuis 2023

    @PostMapping("/{id}/delete-self")
    public ResponseEntity<?> supprimerMonCompte(@PathVariable Long id, @RequestBody Map<String, String> body){
        User userConnecte = getUserConnecte();
        if(!userConnecte.getId().equals(id)){ 
            return ResponseEntity.status(403).body(Map.of("error", "Vous ne pouvez supprimer que votre Compte"));
        }

        String motDePasse = body.get("motDePasse");

        if(motDePasse == null || !passwordEncoder.matches(motDePasse, userConnecte.getMotDePasse())){
            return ResponseEntity.status(401).body(Map.of("error", "Mot de Passe incorrecte. Veuillez utiliser le mot de passe correct."));
        }

        userService.deleteUser(id);
        return ResponseEntity.ok(Map.of("message", "Compte supprimé , vous devrez recréer un compte pour accéder aux services"));
    }

    // concernant le chagement de email et le changement de telephone


        
    @PostMapping("/{id}/change-email/request")
    public ResponseEntity<?> demanderChangementEmail(@PathVariable Long id, @Valid @RequestBody ChangeContactRequest request) {
        User userConnecte = getUserConnecte();
        if (!userConnecte.getId().equals(id)) {
        return ResponseEntity.status(403).body(Map.of("error", "Vous ne pouvez modifier que votre propre compte"));
        }
        try {
            userService.demanderChangementEmail(id, request.getNouvelleValeur());
            return ResponseEntity.ok(Map.of("message", "Un code de vérification a été envoyé au nouvel email"));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @PostMapping("/{id}/change-email/confirm")
    public ResponseEntity<?> confirmerChangementEmail(@PathVariable Long id, @Valid @RequestBody ConfirmCodeRequest request) {
        User userConnecte = getUserConnecte();
        if (!userConnecte.getId().equals(id)) {
        return ResponseEntity.status(403).body(Map.of("error", "Vous ne pouvez modifier que votre propre compte"));
        }
        try {
        userService.confirmerChangementEmail(id, request.getCode());
        return ResponseEntity.ok(Map.of("message", "Email modifié avec succès"));
            } catch (RuntimeException e) {
                return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }   
    }

    @PostMapping("/{id}/change-telephone/request")
    public ResponseEntity<?> demanderChangementTelephone(@PathVariable Long id, @Valid @RequestBody ChangeContactRequest request) {
        User userConnecte = getUserConnecte();
        if (!userConnecte.getId().equals(id)) {
            return ResponseEntity.status(403).body(Map.of("error", "Vous ne pouvez modifier que votre propre compte"));
    }
    try {
        userService.demanderChangementTelephone(id, request.getNouvelleValeur());
        return ResponseEntity.ok(Map.of("message", "Un code de vérification a été envoyé par SMS"));
    } catch (RuntimeException e) {
        return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @PostMapping("/{id}/change-telephone/confirm")
    public ResponseEntity<?> confirmerChangementTelephone(@PathVariable Long id, @Valid @RequestBody ConfirmCodeRequest request) {
        User userConnecte = getUserConnecte();
        if (!userConnecte.getId().equals(id)) {
            return ResponseEntity.status(403).body(Map.of("error", "Vous ne pouvez modifier que votre propre compte"));
    }
    try {
        userService.confirmerChangementTelephone(id, request.getCode());
        return ResponseEntity.ok(Map.of("message", "Téléphone modifié avec succès"));
    }catch (RuntimeException e) {
        return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
    
}