package com.transport.api.scheduler;

import java.time.LocalDateTime;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;

import com.transport.api.repository.NotificationRepository;

public class NotificationCleanUpTask {

  @Autowired
  private NotificationRepository notificationRepository;

  //je veux cet action tjrs à 3h du matin
  @Scheduled(cron = "0 0 3 * * *")
  public void supprimerAnciennesNotifications(){
    LocalDateTime seuil = LocalDateTime.now().minusDays(60);
    notificationRepository.deleteByCreatedAtBefore(seuil);

  }
  
}
