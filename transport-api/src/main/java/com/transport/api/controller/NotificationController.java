package com.transport.api.controller;

import com.transport.api.dto.NotificationBroadcastRequest;
import com.transport.api.model.Notification;
import com.transport.api.model.User;
import com.transport.api.repository.UserRepository;
import com.transport.api.service.NotificationService;

import jakarta.validation.Valid;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/notifications")
public class NotificationController {

    @Autowired
    private NotificationService notificationService;

    @Autowired
    private UserRepository userRepository;

    //  UTILTAIRES SÉCURITÉE (identiques dans chaque Controller protégé) 

    private User getUserConnecte() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String telephone = authentication.getName();
        return userRepository.findByTelephone(telephone)
                .orElseThrow(() -> new RuntimeException("Utilisateur connecté introuvable"));
    }

    private boolean estAdmin(User user) {
        return user.getRole().equals("admin_agence") || user.getRole().equals("super_admin");
    }

    

    // Liste complet — réservée aux admins
    @GetMapping
    public ResponseEntity<?> getAllNotifications() {
        User userConnecte = getUserConnecte();
        if (!estAdmin(userConnecte)) {
            return ResponseEntity.status(403).body(Map.of("error", "Accès réservé aux administrateurs"));
        }
        return ResponseEntity.ok(notificationService.getAllNotifications());
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getNotificationById(@PathVariable Long id) {
        User userConnecte = getUserConnecte();

        return notificationService.getNotificationById(id)
                .map(notification -> {
                    if (!notification.getUser().getId().equals(userConnecte.getId()) && !estAdmin(userConnecte)) {
                        return ResponseEntity.status(403).body(Map.of("error", "Cette notification ne vous appartient pas"));
                    }
                    return ResponseEntity.ok(notification);
                })
                .orElse(ResponseEntity.notFound().build());
    }

    // "Mes notifications" côté app Client — IDOR protégé
    @GetMapping("/user/{userId}")
    public ResponseEntity<?> getNotificationsByUser(@PathVariable Long userId) {
        User userConnecte = getUserConnecte();

        if (!userConnecte.getId().equals(userId) && !estAdmin(userConnecte)) {
            return ResponseEntity.status(403).body(Map.of("error", "Vous ne pouvez consulter que vos propres notifications"));
        }

        return ResponseEntity.ok(notificationService.getNotificationsByUser(userId));
    }

    @GetMapping("/user/{userId}/unread")
    public ResponseEntity<?> getUnreadNotifications(@PathVariable Long userId) {
        User userConnecte = getUserConnecte();

        if (!userConnecte.getId().equals(userId) && !estAdmin(userConnecte)) {
            return ResponseEntity.status(403).body(Map.of("error", "Vous ne pouvez consulter que vos propres notifications"));
        }

        return ResponseEntity.ok(notificationService.getUnreadNotifications(userId));
    }


    // Création — usage interne serveur uniquement (envoyée automatiquement par le système, pas par un client)
    @PostMapping
    public Notification createNotification(@RequestBody Notification notification) {
        return notificationService.createNotification(notification);
    }

    // Marquer comme lue — IDOR protégé
    @PutMapping("/{id}/read")
    public ResponseEntity<?> markAsRead(@PathVariable Long id) {
        User userConnecte = getUserConnecte();

        return notificationService.getNotificationById(id)
                .map(notification -> {
                    if (!notification.getUser().getId().equals(userConnecte.getId())) {
                        return ResponseEntity.status(403).body(Map.of("error", "Cette notification ne vous appartient pas"));
                    }
                    return ResponseEntity.ok(notificationService.markAsRead(id));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteNotification(@PathVariable Long id) {
        notificationService.deleteNotification(id);
        return ResponseEntity.ok().build();
    }

    // un nouveau endpoint pour le lancement de message à un groupe (broadcast)
    @PostMapping("/broadcast")
    public ResponseEntity<?> broadcast(@Valid @RequestBody NotificationBroadcastRequest request){
        User userConnecte = getUserConnecte();

        if(!estAdmin(userConnecte)){
            return ResponseEntity.status(403).body(Map.of("error", "Accès réservé aux administrateurs."));
        }

        if(request.isTousLesUsers() && userConnecte.getRole().equals("admin_agence")){
            // on ne fait rien car je veux que un admin agence a les droits sur ses clients seuls
        }

        try{

            List<Notification> resultat = notificationService.broadcast(request, userConnecte);
            
            return ResponseEntity.ok(Map.of("message", "Notification envoyée à "+ resultat.size()+" utilisateurs", "count ",resultat.size()));
        } catch (RuntimeException e){
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }


}