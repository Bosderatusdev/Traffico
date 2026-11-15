package com.transport.api.dto;

import java.util.List;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data 
public class NotificationBroadcastRequest {

  // si je veux l'envoi de notification/message aux users par broadcast

  @NotBlank(message = "Le titre est obligatoire.")
  private  String titre;

  @NotBlank(message = "Le message est obligatoire")
  private String message;

  private  List<Long> userIds;

  private  boolean tousLesUsers = false;


  
}
