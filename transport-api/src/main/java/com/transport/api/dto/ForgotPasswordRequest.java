package com.transport.api.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class ForgotPasswordRequest {
  @NotBlank(message = "Identifiant obligatoire(Email ou téléphone)")
  private String identifiant ; // Telephone ou email 
  
}
