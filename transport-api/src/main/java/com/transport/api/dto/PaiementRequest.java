package com.transport.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Data;

@Data
public class PaiementRequest {

    @NotBlank(message = "Le groupe de réservation est obligatoire")
    private String groupeId;

    @NotNull(message = "Le montant est obligatoire")
    @Positive(message = "Le montant doit être positif")
    private Double montant;

    private String methode;
}