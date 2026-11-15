package com.transport.api.model;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Entity
@Table(name = "trajets")
@Data
public class Trajet {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @ManyToOne
  @JoinColumn(name="agence_id")
  private Agence agence;

  @ManyToOne
  @JoinColumn(name = "bus_id")
  private Bus bus;

  @Column(name="ville_depart",nullable = false)
  private String villeDepart;

  @Column(name = "ville_arrivee",nullable = false)
  private String villeArrivee;

  @Column(name = "heure_depart",nullable = false)
  private LocalDateTime heureDepart;

  @Column(name = "heure_arrivee")
  private LocalDateTime heureArrivee;

  @Column(nullable = false)
  private Double tarif;

  @Column(name = "places_disponibles")
  private Integer placesDisponibles;

  private String statut = "actif";
  
}
