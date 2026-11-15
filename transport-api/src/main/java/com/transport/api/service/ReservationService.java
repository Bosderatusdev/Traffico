package com.transport.api.service;

import com.transport.api.dto.ReservationRequest;
import com.transport.api.model.Reservation;
import com.transport.api.model.Trajet;
import com.transport.api.model.User;
import com.transport.api.repository.ReservationRepository;
import com.transport.api.repository.TrajetRepository;
import com.transport.api.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
public class ReservationService {

    @Autowired
    private ReservationRepository reservationRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private TrajetRepository trajetRepository;

    public List<Reservation> getAllReservations() {
        return reservationRepository.findAll();
    }

    public Optional<Reservation> getReservationById(Long id) {
        return reservationRepository.findById(id);
    }

    public List<Reservation> getReservationsByUser(Long userId) {
        return reservationRepository.findByUserId(userId);
    }

    public List<Reservation> getReservationsByTrajet(Long trajetId) {
        return reservationRepository.findByTrajetId(trajetId);
    }

    // Créer une nouvelle réservation (userId vient du token, pas du client)


    public List<Reservation> createReservation(Long userId, ReservationRequest request){
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("Utilisateur introuvable"));

        Trajet trajet = trajetRepository.findById(request.getTrajetId())
            .orElseThrow(() -> new RuntimeException("Trajet introuvable"));

        if (trajet.getPlacesDisponibles() < request.getNombrePlaces()) {
            throw new RuntimeException("Places insuffisantes sur ce trajet");
        }

        String groupeId = java.util.UUID.randomUUID().toString();
        List<Reservation> reservationsCreees = new java.util.ArrayList<>();

        for (int i = 1; i <= request.getNombrePlaces(); i++) {
            Reservation reservation = new Reservation();
            reservation.setUser(user);
            reservation.setTrajet(trajet);
            reservation.setNumeroSiege("Place " + i + "/" + request.getNombrePlaces());
            reservation.setStatut("en_attente");
            reservation.setGroupeId(groupeId);
            reservation.setQrCode(java.util.UUID.randomUUID().toString());
            reservationsCreees.add(reservationRepository.save(reservation));
        }

        return reservationsCreees;
    }
   
    public Reservation updateReservation(Long id, Reservation reservationDetails) {
        Reservation reservation = reservationRepository.findById(id).orElseThrow();
        reservation.setNumeroSiege(reservationDetails.getNumeroSiege());
        reservation.setStatut(reservationDetails.getStatut());
        return reservationRepository.save(reservation);
    }

    public void deleteReservation(Long id) {
        reservationRepository.deleteById(id);
    }
}