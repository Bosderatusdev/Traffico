package com.transport.api.model;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Entity
@Table(name = "agences")
@Data
public class Agence {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String nom;

    private String telephone;
    private String email;

    @Column(name = "logo_url")
    private String logoUrl;

    private String statut = "en_attente";

    private Double commission = 0.00;

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();
}