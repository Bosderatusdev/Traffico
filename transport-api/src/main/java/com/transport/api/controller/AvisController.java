package com.transport.api.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.transport.api.model.Avis;
import com.transport.api.service.AvisService;

@RestController
@RequestMapping("/api/avis")
public class AvisController {
  @Autowired
  private AvisService avisService;

  //GET - récupérer tous les avis
  @GetMapping
  public List<Avis> getAllAvis(){
    return avisService.getAllAvis();
  }

  //GET - récupérer un avis par ID
  @GetMapping("/{id}")
  public ResponseEntity<Avis> getAvisById(@PathVariable Long id){
    return avisService.getAvisById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
  }

  //GET - récupérer les avis d'une agence
  @GetMapping("/agence/{agenceId}")
  public List<Avis> getAvisByAgence(@PathVariable Long agenceId){
    return avisService.getAvisByAgence(agenceId);
  }

  //GET - récupérer les avis d'un user
  @GetMapping("/user/{userId}")
  public List<Avis> getAvisByUser(@PathVariable Long userId){
    return avisService.getAvisByUser(userId);
  }

  //POST - créer un avis
  @PostMapping
  public Avis createAvis(@RequestBody Avis avis){
    return avisService.createAvis(avis);
  }

  //PUT - modifier un avis
  @PutMapping("/{id}")
  public ResponseEntity<Avis> updateAvis(@PathVariable Long id,@RequestBody Avis avis){

    try{
      return ResponseEntity.ok(avisService.updateAvis(id, avis));
    }catch(Exception e){
      return ResponseEntity.notFound().build();
    }
  }

  //DELETE - supprimer un avis
  @DeleteMapping("/{id}")
  public ResponseEntity<Void> deleteAvis(@PathVariable Long id){
    avisService.deleteAvis(id);
    return ResponseEntity.ok().build();
  }
  
}
