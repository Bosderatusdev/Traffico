package com.transport.api.model;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "chauffeurs")
@Data
public class Chauffeur {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @ManyToOne
  @JoinColumn(name = "agence_id")
  private Agence agence;

  @OneToOne 
  @JoinColumn(name = "user_id")
  private  User user;

  @Column(nullable = false)
  private String nom;

  private String prenom;

  private String telephone;


  @Column(name = "numero_permis")
  private String numeroPermis;

  private String statut ="actif";



  
}
