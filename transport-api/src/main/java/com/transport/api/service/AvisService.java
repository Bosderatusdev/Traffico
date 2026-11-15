package com.transport.api.service;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.transport.api.model.Avis;
import com.transport.api.repository.AvisRepository;

@Service
public class AvisService {
  
  @Autowired
  private AvisRepository avisRepository;

  //récupérer tous les avis
  public List<Avis> getAllAvis(){
    return avisRepository.findAll();
  }

  //récupérer un avis par ID
  public Optional<Avis> getAvisById(Long id){
    return avisRepository.findById(id);
  }

  //récupérer les avis d'une agence
  public List<Avis> getAvisByAgence(Long agenceId){
    return avisRepository.findByAgenceId(agenceId);
  }

  //récupérer les avis d'un user
  public List<Avis> getAvisByUser(Long userId){
    return avisRepository.findByUserId(userId);
  }

  //créer un avis
  public Avis createAvis(Avis avis){
    return avisRepository.save(avis);
  }

  //modifier un avis
  public Avis updateAvis(Long id,Avis avisDetails){
    Avis avis = avisRepository.findById(id).orElseThrow();
    avis.setNote(avisDetails.getNote());
    avis.setCommentaire(avisDetails.getCommentaire());
    return avisRepository.save(avis);
  }

  //supprimer un avis
  public void deleteAvis(Long id){
    avisRepository.deleteById(id);
  }
  
}
