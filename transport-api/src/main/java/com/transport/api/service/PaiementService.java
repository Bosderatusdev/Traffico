package com.transport.api.service;

import com.transport.api.dto.PaiementConfirmationResponse;
import com.transport.api.dto.PaiementRequest;
import com.transport.api.model.Notification;
import com.transport.api.model.Paiement;
import com.transport.api.model.Reservation;
import com.transport.api.model.Trajet;
import com.transport.api.repository.NotificationRepository;
import com.transport.api.repository.PaiementRepository;
import com.transport.api.repository.ReservationRepository;
import com.transport.api.repository.TrajetRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.transport.api.dto.PaiementConfirmationResponse;

import java.util.List;
import java.util.Optional;

@Service
public class PaiementService {

    @Autowired
    private PaiementRepository paiementRepository;

    @Autowired
    private ReservationRepository reservationRepository;

    @Autowired
    private TrajetRepository trajetRepository;

    @Autowired
    private NotificationRepository notificationRepository;

    public List<Paiement> getAllPaiements() {
        return paiementRepository.findAll();
    }

    public Optional<Paiement> getPaiementById(Long id) {
        return paiementRepository.findById(id);
    }

    public Optional<Paiement> getPaiementByGroupe(String groupeId) {
        return paiementRepository.findByGroupeId(groupeId);
    }

    // Créer un paiement pour un groupe de réservations
    public Paiement createPaiement(PaiementRequest request) {
        Paiement paiement = new Paiement();
        paiement.setGroupeId(request.getGroupeId());
        paiement.setMontant(request.getMontant());
        paiement.setMethode(request.getMethode() != null ? request.getMethode() : "lumicash");
        paiement.setStatut("en_attente");
        return paiementRepository.save(paiement);
    }

    // Confirmer un paiement — TODO futur : remplacer cet appel manuel par un vrai webhook Lumicash
    // C'est ICI que se déclenchent la décrémentation des places et les notifications

    public PaiementConfirmationResponse confirmerPaiement(Long paiementId) {
        Paiement paiement = paiementRepository.findById(paiementId)
            .orElseThrow(() -> new RuntimeException("Paiement introuvable"));

        List<Reservation> reservations = reservationRepository.findByGroupeId(paiement.getGroupeId());

        if (reservations.isEmpty()){
        throw new RuntimeException("Aucune réservation trouvée pour ce paiement");
        }

        // Si déjà confirmé, on ne refait pas la décrémentation/notifications, mais on renvoie quand même le résumé
        if (!"reussi".equals(paiement.getStatut())) {
            paiement.setStatut("reussi");
            paiementRepository.save(paiement);

            // une renvoi de notification par paiement final effectué n'importe qul nombre de places réservés
            Notification confirmation = new Notification();
            confirmation.setUser(reservations.get(0).getUser());
            confirmation.setTitre("Paiement confirmé");
            confirmation.setMessage("Votre paiement de"+paiement.getMontant()+" FBu pour "+reservations.size()+" place(s) a été confirmé.\nVos billets sont disponibles.");

            notificationRepository.save(confirmation);

            for(Reservation reservation : reservations){
                reservation.setStatut("confirmee");
                reservationRepository.save(reservation);

                Notification billet = new Notification();
                billet.setUser(reservation.getUser());
                billet.setTitre("Billet de réservation");
                billet.setMessage("Trajet " + reservation.getTrajet().getVilleDepart() + " → "
                    + reservation.getTrajet().getVilleArrivee() + ", " + reservation.getNumeroSiege()
                    + ", départ le " + reservation.getTrajet().getHeureDepart());
            notificationRepository.save(billet);

            Notification qr = new Notification();
            qr.setUser(reservation.getUser());
            qr.setTitre("QR Code de votre billet");
            qr.setMessage(reservation.getQrCode());
            notificationRepository.save(qr);
        }

        Trajet trajet = reservations.get(0).getTrajet();
        trajet.setPlacesDisponibles(trajet.getPlacesDisponibles() - reservations.size());
        trajetRepository.save(trajet);
    }

    // Construction de la réponse enrichie (dans tous les cas, même si déjà confirmé avant)
    Trajet trajet = reservations.get(0).getTrajet();

    PaiementConfirmationResponse response = new PaiementConfirmationResponse();
        response.setPaiementId(paiement.getId());
        response.setStatut(paiement.getStatut());
        response.setMontant(paiement.getMontant());
        response.setMethode(paiement.getMethode());
        response.setVilleDepart(trajet.getVilleDepart());
        response.setVilleArrivee(trajet.getVilleArrivee());
        response.setHeureDepart(trajet.getHeureDepart().toString());
        response.setNomAgence(trajet.getAgence() != null ? trajet.getAgence().getNom() : null);
        response.setNombrePlaces(reservations.size());
        response.setQrCodes(reservations.stream().map(Reservation::getQrCode).collect(java.util.stream.Collectors.toList()));

        return response;
    }

    public void deletePaiement(Long id) {
        paiementRepository.deleteById(id);
    }
}