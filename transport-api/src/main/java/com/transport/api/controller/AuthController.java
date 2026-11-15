package com.transport.api.controller;

import com.transport.api.dto.ForgotPasswordRequest;
import com.transport.api.dto.LoginRequest;
import com.transport.api.dto.RegisterRequest;
import com.transport.api.dto.ResetPasswordRequest;
import com.transport.api.model.User;
import com.transport.api.repository.UserRepository;
import com.transport.api.security.JwtUtil;
import com.transport.api.service.VerificationService;

import jakarta.validation.Valid;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;


@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private VerificationService verificationService;

    @Autowired
    private PasswordEncoder passwordEncoder;

    // INSCRIPTION
    @PostMapping("/register")
    public ResponseEntity<?> register(@Valid @RequestBody RegisterRequest request) {

        if (userRepository.findByTelephone(request.getTelephone()).isPresent()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Ce numéro de téléphone est déjà utilisé"));
        }

        if (request.getEmail() != null && !request.getEmail().isEmpty()
                && userRepository.findByEmail(request.getEmail()).isPresent()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Cet email est déjà utilisé"));
        }

        User user = new User();
        user.setNom(request.getNom());
        user.setPrenom(request.getPrenom());
        user.setTelephone(request.getTelephone());
        user.setEmail(request.getEmail());
        user.setMotDePasse(passwordEncoder.encode(request.getMotDePasse()));
        user.setRole("client");

        userRepository.save(user);

        // Envoyer le code de vérification téléphone (obligatoire)
        verificationService.sendPhoneVerification(user);

        // Envoyer le code de vérification email (si fourni)
        if (user.getEmail() != null && !user.getEmail().isEmpty()) {
            verificationService.sendEmailVerification(user);
        }

        return ResponseEntity.ok(Map.of(
                "message", "Inscription réussie ! Un code de vérification a été envoyé par SMS" +
                        (user.getEmail() != null ? " et par email" : "") + ".",
                "userId", user.getId()
        ));
    }

    // VÉRIFIER LE CODE TÉLÉPHONE
    @PostMapping("/verify-phone")
    public ResponseEntity<?> verifyPhone(@RequestBody Map<String, String> body) {
        Long userId = Long.parseLong(body.get("userId"));
        String code = body.get("code");

        User user = userRepository.findById(userId).orElseThrow();

        if (verificationService.verifyPhoneCode(user, code)) {
            return ResponseEntity.ok(Map.of("message", "Numéro de téléphone vérifié avec succès !"));
        } else {
            return ResponseEntity.badRequest().body(Map.of("error", "Code invalide ou expiré"));
        }
    }

    // VÉRIFIER LE CODE EMAIL
    @PostMapping("/verify-email")
    public ResponseEntity<?> verifyEmail(@RequestBody Map<String, String> body) {
        Long userId = Long.parseLong(body.get("userId"));
        String code = body.get("code");

        User user = userRepository.findById(userId).orElseThrow();

        if (verificationService.verifyEmailCode(user, code)) {
            return ResponseEntity.ok(Map.of("message", "Email vérifié avec succès !"));
        } else {
            return ResponseEntity.badRequest().body(Map.of("error", "Code invalide ou expiré"));
        }
    }

    // CONNEXIOn
    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequest request) {

        Optional<User> userOpt = userRepository.findByTelephone(request.getIdentifiant());
        if (userOpt.isEmpty()) {
            userOpt = userRepository.findByEmail(request.getIdentifiant());
        }

        if (userOpt.isEmpty()) {
            return ResponseEntity.status(401).body(Map.of("error", "Email ou Téléphone incorrect"));
        }

        User user = userOpt.get();

        if (!passwordEncoder.matches(request.getMotDePasse(), user.getMotDePasse())) {
            return ResponseEntity.status(401).body(Map.of("error", "Mot de passe incorrect"));
        }

        String token = jwtUtil.generateToken(user.getTelephone(), user.getRole(), user.getTokenVersion());

        Map<String, Object> response = new HashMap<>();
        response.put("token", token);
        response.put("userId", user.getId());
        response.put("nom", user.getNom());
        response.put("role", user.getRole());
        response.put("telephoneVerifie", user.getTelephoneVerifie());
        response.put("emailVerifie", user.getEmailVerifie());

        return ResponseEntity.ok(response);
    }

    //pour la déconnexion

    @PostMapping("/logout-all-devices")
    public ResponseEntity<?> logoutAllDevices() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String telephone = authentication.getName();

        User user = userRepository.findByTelephone(telephone)
            .orElseThrow(() -> new RuntimeException("Utilisateur introuvable"));

        user.setTokenVersion(user.getTokenVersion() + 1);
        userRepository.save(user);

        return ResponseEntity.ok(Map.of("message", "Tous les appareils ont été déconnectés."));
    }





    // === MOT DE PASSE OUBLIÉ ===

    // Étape 1 — Demander un code de réinitialisation
    @PostMapping("/forgot-password")
    public ResponseEntity<?> forgotPassword(@Valid @RequestBody ForgotPasswordRequest request) {

        Optional<User> userOpt = userRepository.findByTelephone(request.getIdentifiant());
        if (userOpt.isEmpty()) {
            userOpt = userRepository.findByEmail(request.getIdentifiant());
        }

        // Message générique volontaire — évite de révéler si l'identifiant existe ou non
        if (userOpt.isEmpty()) {
            return ResponseEntity.ok(Map.of("message", "Si ce compte existe, un code a été envoyé."));
        }

        User user = userOpt.get();

        // Envoie par email si l'identifiant fourni est un email connu, sinon par téléphone
        boolean estEmail = user.getEmail() != null && user.getEmail().equals(request.getIdentifiant());

        if (estEmail) {
            verificationService.sendPasswordResetEmail(user);
        } else {
            verificationService.sendPasswordResetSms(user);
        }

        return ResponseEntity.ok(Map.of("message", "Si ce compte existe, un code a été envoyé."));
    }

    // Étape 2 — Vérifier le code et définir le nouveau mot de passe
    @PostMapping("/reset-password")
    public ResponseEntity<?> resetPassword(@Valid @RequestBody ResetPasswordRequest request) {

        Optional<User> userOpt = userRepository.findByTelephone(request.getIdentifiant());
        if (userOpt.isEmpty()) {
            userOpt = userRepository.findByEmail(request.getIdentifiant());
        }

        if (userOpt.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Code invalide ou expiré"));
        }

        User user = userOpt.get();

        if (!verificationService.verifyResetCode(user, request.getCode())) {
            return ResponseEntity.badRequest().body(Map.of("error", "Code invalide ou expiré"));
        }

        user.setMotDePasse(passwordEncoder.encode(request.getNouveauMotDePasse()));
        user.setTokenVersion(user.getTokenVersion() + 1);
        userRepository.save(user);
        verificationService.clearResetCode(user);

        return ResponseEntity.ok(Map.of("message", "Mot de passe réinitialisé avec succès !"));
    }



    // RENVOYER LE CODE (téléphone ou email selon le type demandé)
    @PostMapping("/resend-code")
    public ResponseEntity<?> resendCode(@RequestBody Map<String, String> body) {
        Long userId = Long.parseLong(body.get("userId"));
        String type = body.get("type"); // "phone" ou "email"

        User user = userRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("Utilisateur introuvable"));

        if ("phone".equals(type)) {
            verificationService.sendPhoneVerification(user);
            return ResponseEntity.ok(Map.of("message", "Un nouveau code a été envoyé par SMS."));
        } else if ("email".equals(type)) {
            if (user.getEmail() == null || user.getEmail().isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of("error", "Aucun email associé à ce compte"));
        }
            verificationService.sendEmailVerification(user);
            return ResponseEntity.ok(Map.of("message", "Un nouveau code a été envoyé par email."));
        } else {
            return ResponseEntity.badRequest().body(Map.of("error", "Type invalide (attendu: 'phone' ou 'email')"));
        }
    }
    





}
