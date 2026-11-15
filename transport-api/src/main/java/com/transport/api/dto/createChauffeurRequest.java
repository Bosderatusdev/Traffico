package com.transport.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data 
public class createChauffeurRequest {
  @NotBlank(message = "Le nom est obligatoire")
  private  String nom;

  private  String prenom;

  @NotBlank(message = "Le téléphone est obligatoire")
  @Pattern(regexp = "^\\+?[0-9]{8,15}$", message = "Numéro de téléphone invalide")
  private  String telephone;

  @NotBlank(message = "Le mot de passe de base est obligatoire")
  @Size(min = 6,message = "Le mot de passe doit contenir au moins 6 caractères")
  private  String motDePasse;

  private  String numeroPermis;

  private  Long agenceId;

  
}
