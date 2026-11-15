package com.transport.api.service;

import com.transport.api.model.Trajet;
import com.transport.api.repository.TrajetRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class TrajetService {
  @Autowired
  private TrajetRepository trajetRepository;

  //Récupérer tous les trajets 
  public List<Trajet> getAllTrajets(){
    return trajetRepository.findAll();
  }

  //Récupérer un trajet par ID
  public Optional<Trajet> getTrajetById(Long id){
    return trajetRepository.findById(id);
  }

  //récupérer les trajets d'une agence
  public List<Trajet> getTrajetByAgence(Long agenceId){
    return trajetRepository.findByAgenceId(agenceId);
  }

  //Rechercher des trajets (départ → arrivée)
  public List<Trajet> searchTrajets(String VilleDepart,String VilleArrivee){
    return trajetRepository.findByVilleDepartContainingIgnoreCaseAndVilleArriveeContainingIgnoreCase(VilleDepart, VilleArrivee);
  }

  //Créer un nouveau trajet
  public Trajet createTrajet(Trajet trajet){
    return trajetRepository.save(trajet);
  }

  //modifier un trajet
  public Trajet updateTrajet(Long id,Trajet trajetDetails){
      Trajet trajet = trajetRepository.findById(id).orElseThrow();
      trajet.setVilleDepart(trajetDetails.getVilleDepart());
      trajet.setVilleArrivee(trajetDetails.getVilleArrivee());
      trajet.setHeureDepart(trajetDetails.getHeureDepart());
      trajet.setHeureArrivee(trajetDetails.getHeureArrivee());
      trajet.setTarif(trajetDetails.getTarif());
      trajet.setPlacesDisponibles(trajetDetails.getPlacesDisponibles());
      trajet.setStatut(trajetDetails.getStatut());
      return trajetRepository.save(trajet);
  }

  //supprimer un trajet

  public void deleteTrajet(Long id){
    trajetRepository.deleteById(id);
  }
  
}
