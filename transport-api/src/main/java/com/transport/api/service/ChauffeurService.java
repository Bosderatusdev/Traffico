package com.transport.api.service;

import com.transport.api.dto.createChauffeurRequest;
import com.transport.api.model.Agence;
import com.transport.api.model.Chauffeur;
import com.transport.api.model.User;
import com.transport.api.repository.ChauffeurRepository;
import com.transport.api.repository.UserRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class ChauffeurService {
  @Autowired
  private ChauffeurRepository chauffeurRepository;

  @Autowired
  private UserRepository userRepository;


  @Autowired
  private  org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder passwordEncoder;

  //récupérer tous les chauffeurs
  public List<Chauffeur> getAllChauffeurs(){
    return chauffeurRepository.findAll();
  }

  //récuperer un chauffeur par ID

  public Optional<Chauffeur> getChauffeurById(Long id){
    return chauffeurRepository.findById(id);
  }

  //récupérer tous les chauffeurs d'une agence

  public List<Chauffeur> getChauffeursByAgence(Long AgenceId){
    return chauffeurRepository.findByAgenceId(AgenceId);
  }

  //Créer un nouveau chauffeur

  public Chauffeur createChauffeur(Chauffeur chauffeur){
    return chauffeurRepository.save(chauffeur);
  }

  //Modifier un chauffeur

  public Chauffeur updateChauffeur(Long id,Chauffeur chauffeurDetails){
    Chauffeur chauffeur = chauffeurRepository.findById(id).orElseThrow();
    chauffeur.setNom(chauffeurDetails.getNom());
    chauffeur.setTelephone(chauffeurDetails.getTelephone());
    chauffeur.setNumeroPermis(chauffeurDetails.getNumeroPermis());
    chauffeur.setStatut(chauffeurDetails.getStatut());
    return chauffeurRepository.save(chauffeur);
    
  }

  //Supprimer un chauffeur
  public void deleteChauffeur(Long id){
    chauffeurRepository.deleteById(id);
  }

  //La création du chauffeur (user avec role= chauffeur  et chauffeur)

  public Chauffeur createChauffeurAvecCompte(createChauffeurRequest request, Agence agence){

    if(userRepository.findByTelephone(request.getTelephone()).isPresent()){
      throw new RuntimeException("Ce numéro de téléphone est déjà utilisé");
    }

    User user = new  User();

    user.setNom(request.getNom());
    user.setPrenom(request.getPrenom());
    user.setTelephone(request.getTelephone());
    user.setMotDePasse(passwordEncoder.encode(request.getMotDePasse()));
    user.setRole("chauffeur");
    user.setAgence(agence);
    user.setTelephoneVerifie(true);
    userRepository.save(user);

    Chauffeur chauffeur = new Chauffeur();
    chauffeur.setNom(request.getNom());
    chauffeur.setPrenom(request.getPrenom());
    chauffeur.setNumeroPermis(request.getNumeroPermis());
    chauffeur.setTelephone(request.getTelephone());
    chauffeur.setStatut("actif");
    chauffeur.setAgence(agence);
    chauffeur.setUser(user);

    return chauffeurRepository.save(chauffeur);


  }



  
}
