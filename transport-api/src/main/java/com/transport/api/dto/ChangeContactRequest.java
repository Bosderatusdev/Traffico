package com.transport.api.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data 
public class ChangeContactRequest {
  @NotBlank (message = "Le nouveau phone/mail est obligatoire")
  private String nouvelleValeur; // un nveau email ou un nv telephone
}
