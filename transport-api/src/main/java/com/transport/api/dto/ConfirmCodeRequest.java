package com.transport.api.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data 
public class ConfirmCodeRequest {
  @NotBlank (message = "Le code est obligatoire")
  private String code;
  
}
