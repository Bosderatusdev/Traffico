package com.transport.api.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class LoginRequest {
  @NotBlank(message = "Identifiant obligatoire (téléphone ou email")
  private String identifiant;

  @NotBlank(message = "Le mot de passe est obligatoire")
  private String motDePasse;

  
}


