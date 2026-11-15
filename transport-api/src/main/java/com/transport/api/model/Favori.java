package com.transport.api.model;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Data;

@Entity 
@Table(name = "favoris")
@Data
public class Favori {
  @Id 
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @ManyToOne
  @JoinColumn(name = "user_id",nullable = false)
  private User user;

  @Column(nullable = false)
  private String type; //"agence" ou "trajet"

  @ManyToOne
  @JoinColumn(name = "agence_id")
  private Agence agence;

  @Column(name = "ville_depart")
  private String villeDepart;

  @Column(name = "ville_arrivee")
  private String villeArrivee;

  @Column(name = "created_at")
  private LocalDateTime createdAt = LocalDateTime.now();

  

  

}
