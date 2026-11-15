package com.transport.api.controller;

import com.transport.api.model.Trajet;
import com.transport.api.service.TrajetService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/trajets")
public class TrajetController {

  @Autowired
  private TrajetService trajetService;

   // GET — Récupérer tous les trajets
    @GetMapping
    public List<Trajet> getAllTrajets() {
        return trajetService.getAllTrajets();
    }

  //GET - Récupérer un trajet par ID
  @GetMapping("/{id}")
  public ResponseEntity<Trajet> getTrajetById(@PathVariable Long id){
    return trajetService.getTrajetById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
  }

  //GET - récupérer les trajets d'une agence
  @GetMapping("/agence/{agenceId}")
  public List<Trajet> getTrajetsByAgence(@PathVariable Long agenceId){
    return trajetService.getTrajetByAgence(agenceId);
  }

  // GET — Rechercher des trajets (départ → arrivée)
  @GetMapping("/search")
  public List<Trajet> searchTrajets(@RequestParam String depart,@RequestParam String arrivee){
    return trajetService.searchTrajets(depart, arrivee);
  }

  //POST - créer un trajet
  @PostMapping
  public Trajet createTrajet(@RequestBody Trajet trajet){
    return trajetService.createTrajet(trajet);
  }

  //PUT - modifier un trajet
  @PutMapping("/{id}")
  public ResponseEntity<Trajet> updateTrajet(@PathVariable Long id,@RequestBody Trajet trajet){
    try{
      return ResponseEntity.ok(trajetService.updateTrajet(id, trajet));
    }catch(Exception e){
      return ResponseEntity.notFound().build();
    }
  }

  //DELETE - supprimer un trajet
  @DeleteMapping("/{id}")
  public ResponseEntity<Trajet> deleteTrajet(@PathVariable Long id){
    trajetService.deleteTrajet(id);
    return ResponseEntity.ok().build();
  }




  



}
