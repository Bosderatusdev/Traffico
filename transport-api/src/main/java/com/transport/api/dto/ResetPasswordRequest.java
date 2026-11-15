package com.transport.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class ResetPasswordRequest {
  @NotBlank(message = "Identifiant obligatoire")
  private String identifiant; 

  @NotBlank(message = "Le code obligatoire")
  private String code;

  @NotBlank(message = "Le nouveau mot de passe est obligatoire")
  @Size(min = 6, message = "Le mot de passe doit contenir au moins 6 caractères")
  private String nouveauMotDePasse;

  
}
