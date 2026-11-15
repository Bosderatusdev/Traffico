package com.transport.api.controller;

import com.transport.api.dto.createChauffeurRequest;
import com.transport.api.model.Agence;
import com.transport.api.model.Chauffeur;
import com.transport.api.model.User;
import com.transport.api.repository.AgenceRepository;
import com.transport.api.repository.UserRepository;
import com.transport.api.service.ChauffeurService;

import jakarta.validation.Valid;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.PathVariable;




@RestController
@RequestMapping("/api/chauffeurs")
public class ChauffeurController {

  @Autowired
  private UserRepository userRepository;

  @Autowired
  private  AgenceRepository agenceRepository;


  @Autowired
  private ChauffeurService chauffeurService;

  private  User getUserConnecte(){
    Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
    String telephone = authentication.getName();

    return userRepository.findByTelephone(telephone)
              .orElseThrow(() -> new RuntimeException("Utilisateur introuvable"));

    
  }

  //GET - récupérer tous les chauffeurs
  @GetMapping
  public List<Chauffeur> getAllChauffeurs(){
    return chauffeurService.getAllChauffeurs();
  }

  //GET - récupérer un chauffeur par ID

  @GetMapping("/{id}")
  public ResponseEntity<Chauffeur> getChauffeurById(@PathVariable Long Id){
    return chauffeurService.getChauffeurById(Id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());

  }

  //GET - récupérer les chauffeurs d'une agence
  @GetMapping("/agence/{agenceId}")
  public List<Chauffeur> getChauffeursByAgence(@PathVariable Long agenceId){
    return chauffeurService.getChauffeursByAgence(agenceId);
  }

  //POST - Créer un chauffeur et son compte en une seul opération
  @PostMapping
  public ResponseEntity<?> createChauffeur(@Valid @RequestBody createChauffeurRequest request){
    User userConnecte = getUserConnecte();
    
    Agence agence;

    if("super_admin".equals(userConnecte.getRole())){
      if(request.getAgenceId() == null){
        return ResponseEntity.badRequest().body(Map.of("error","agenceId est obligatoire pour un super admin"));
      }

      agence = agenceRepository.findById(request.getAgenceId())
                  .orElseThrow(() -> new RuntimeException("Agence introuvable"));

    }else {

      //admin_agence : tjrs sa propre agence

      agence = userConnecte.getAgence();

    }


    try{
      Chauffeur chauffeur = chauffeurService.createChauffeurAvecCompte(request, agence);
      return ResponseEntity.ok(chauffeur);
    } catch (RuntimeException e){

      return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
    }



    
  }

  //PUT - modifier un chauffeur
  @PutMapping("/{id}")
  public ResponseEntity<Chauffeur> updateChauffeur(@PathVariable Long id, @RequestBody Chauffeur chauffeur){
    try{
      return ResponseEntity.ok(chauffeurService.updateChauffeur(id, chauffeur));
    }catch(Exception e){
      return ResponseEntity.notFound().build();
    }
  }

  //DELETE - Supprimer un chauffeur
  @DeleteMapping("/{id}")
  public ResponseEntity<Void> deleteChauffeur(@PathVariable Long id){
    chauffeurService.deleteChauffeur(id);
    return ResponseEntity.ok().build();
  }

  


 
  
  
}
