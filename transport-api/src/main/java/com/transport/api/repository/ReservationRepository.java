package com.transport.api.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.transport.api.model.Reservation;

@Repository
public interface ReservationRepository extends JpaRepository<Reservation, Long> {
  //TRouver tous les réservation d'un user

  List<Reservation> findByUserId(Long userId);


  //Trouver tous les réservations d'un trajet

  List<Reservation> findByTrajetId(Long trajetId);

  //si il y aurait une persoone qui reserve pour plusieurs places
  List<Reservation> findByGroupeId(String groupeId);

  //pour scanner un qr code

  Optional<Reservation> findByQrCode(String qrCode);

  


}
