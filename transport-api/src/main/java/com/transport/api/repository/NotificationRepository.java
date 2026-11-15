package com.transport.api.repository;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.transport.api.model.Notification;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, Long> {

  //Trouver touss les notifications d'un user
  List<Notification> findByUserId(Long userId);

  //Trouver les notifications non lues d'un user
  List<Notification> findByUserIdAndLu(Long userId, Boolean lu);

  //la suppression de notif
  void deleteByCreatedAtBefore(LocalDateTime seuil);
  
}
