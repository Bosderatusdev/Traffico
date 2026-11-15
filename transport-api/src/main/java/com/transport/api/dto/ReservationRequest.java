package com.transport.api.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class ReservationRequest {

    @NotNull(message = "Le trajet est obligatoire")
    private Long trajetId;

    @NotNull(message = "Le nombre de place(s) est obligatoire")
    @Min(value = 1, message = "Il faut réserver au moins une place")
    private Integer nombrePlaces = 1;
}