package com.transport.api.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data 
public class FavoriRequest {
  @NotBlank(message = "Le type est obligatoire")
  private String type;// "agence" ou "trajet"
  
  private  Long agenceId; // requis si type="agence"

  private String villeDepart; //requis si type = "trajet"

  private String villeArrivee; //requis si type="trajet"

  
  
}
