package com.transport.api.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.transport.api.model.Favori;

public interface FavoriRepository extends JpaRepository<Favori, Long> {
  List<Favori> findByUserId(Long userId);

  Optional<Favori> findByUserIdAndAgenceId(Long userId, Long agenceId);

  Optional<Favori> findByUserIdAndVilleDepartAndVilleArrivee(Long userId, String villeDepart, String villeArrivee);
 


  
}
