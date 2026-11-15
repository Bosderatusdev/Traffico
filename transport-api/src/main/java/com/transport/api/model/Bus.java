package com.transport.api.model;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "bus")
@Data
public class Bus {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @ManyToOne
  @JoinColumn(name = "agence_id")
  private Agence agence;

  private String numero;

  @Column(nullable = false)
  private Integer capacite;

  private String type;

  private String statut="actif";

  
}
