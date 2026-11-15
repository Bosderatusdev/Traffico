package com.transport.api.dto;

import java.util.List;

import lombok.Data;

@Data
public class PaiementConfirmationResponse {
  private Long paiementId;
  private String statut;
  private double montant;
  private String methode;
  private String villeDepart;
  private String villeArrivee;
  private String heureDepart;
  private String nomAgence;
  private int nombrePlaces;
  private List<String> qrCodes;
  
}
