package com.transport.api.model;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Entity
@Table(name = "reservations")
@Data
public class Reservation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    @ManyToOne
    @JoinColumn(name = "trajet_id")
    private Trajet trajet;

    @Column(name = "numero_siege")
    private String numeroSiege;

    private String statut = "en_attente";

    @Column(name = "qr_code")
    private String qrCode;

    // Regroupe toutes les réservations d'un même achat (ex: maman + 2 enfants)
    @Column(name = "groupe_id")
    private String groupeId;

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();
}