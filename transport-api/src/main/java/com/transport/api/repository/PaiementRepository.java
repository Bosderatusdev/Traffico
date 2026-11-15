package com.transport.api.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.transport.api.model.Paiement;
import java.util.List;


@Repository
public interface PaiementRepository extends JpaRepository<Paiement, Long> {

  //Trouver un paiement par sa réservation
  Optional<Paiement>findByReservationId(Long reservationId);

  //Trouver un paiement par son transaction ID (venant de Lumicash/ecocash/etc.);
  Optional<Paiement> findByTransactionId(String transactionId);

  // pour une réservation en groupe

  Optional<Paiement> findByGroupeId(String groupeId);
  
}
