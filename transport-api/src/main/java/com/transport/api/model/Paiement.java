package com.transport.api.model;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Entity
@Table(name = "paiements")
@Data
public class Paiement {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Gardé pour compatibilité historique, plus utilisé comme lien principal
    @ManyToOne
    @JoinColumn(name = "reservation_id")
    private Reservation reservation;

    // Lien principal désormais : couvre toutes les réservations d'un même groupe/achat
    @Column(name = "groupe_id")
    private String groupeId;

    @Column(nullable = false)
    private Double montant;

    // Valeurs possibles : lumicash, ecocash, smart_pesa, burundipay, especes
    private String methode = "lumicash";

    @Column(name = "transaction_id")
    private String transactionId;

    private String statut = "en_attente";

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();
}