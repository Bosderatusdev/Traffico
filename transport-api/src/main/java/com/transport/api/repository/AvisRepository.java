package com.transport.api.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.transport.api.model.Avis;

@Repository
public interface AvisRepository extends JpaRepository<Avis,Long> {

  //TRouver tous les avis d'une agence
  List<Avis> findByAgenceId(Long agenceId);

  //Trouver tous les avis d'un user
  List<Avis> findByUserId(Long userId);


  
}
