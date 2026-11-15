package com.transport.api.service;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.transport.api.dto.NotificationBroadcastRequest;
import com.transport.api.model.Notification;
import com.transport.api.model.User;
import com.transport.api.repository.NotificationRepository;
import com.transport.api.repository.UserRepository;

@Service
public class NotificationService {
  @Autowired
  private NotificationRepository notificationRepository;

  @Autowired 
  private UserRepository userRepository;



  //Récupérer toutes les notifications
  public List<Notification> getAllNotifications(){
    return notificationRepository.findAll();
  }

  //Récupérer une notification par ID
  public Optional<Notification> getNotificationById(Long id){
    return notificationRepository.findById(id);
  }

  //récupérer les notifications d'un user
  public List<Notification> getNotificationsByUser(Long userId){
    return notificationRepository.findByUserId(userId);
  }

  //récupérer les notifications non lues d'un user
  public List<Notification> getUnreadNotifications(Long userId){
    return notificationRepository.findByUserIdAndLu(userId, false);
  }

  //Créer une nouvelle notifications
  public Notification createNotification(Notification notification){
    return notificationRepository.save(notification);
  }

  //Marker une notification comme lue
  public Notification markAsRead(Long id){
    Notification notification = notificationRepository.findById(id).orElseThrow();
    notification.setLu(true);
    return notificationRepository.save(notification);
  }

  //supprimer une notification
  public void deleteNotification(Long id){
    notificationRepository.deleteById(id);
  }

  public List<Notification> broadcast(NotificationBroadcastRequest request, User expéditeur){

    List<User> destinataires;

    if(request.isTousLesUsers()){
      if(expéditeur.getRole().equals("super_admin")){
        //moi en tant que super_admin , j'enverrai à tout le monde les notifs
        destinataires = userRepository.findAll();
      }else if(expéditeur.getRole().equals("admin_agence")){
        // un admin agence , ça sera seulement pour les users qui ont réserver sur son agence
        destinataires = userRepository.findClientsByAgenceId(expéditeur.getAgence().getId());
      }else {
        throw new RuntimeException("Non autorisé à diffuser à tous les utilisateurs.");
      }

    } else {
      if(request.getUserIds() == null || request.getUserIds().isEmpty()){
        throw new RuntimeException("Aucun destinataire spécifié");
      }

      destinataires = userRepository.findAllById(request.getUserIds());
    }


    List<Notification> crees = new java.util.ArrayList<>();

    for(User user : destinataires){
      Notification n = new  Notification();
      n.setUser(user);
      n.setTitre(request.getTitre());
      n.setMessage(request.getMessage());
      crees.add(notificationRepository.save(n));
    }

    return  crees;


  }

  

}
