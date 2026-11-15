package com.transport.api.repository;

import com.transport.api.model.Trajet;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TrajetRepository extends JpaRepository<Trajet, Long> {
  //Trouver les trajets d'une agence
  List<Trajet>findByAgenceId(Long agenceId);

  //recherche des trajets par ville de départ et d'arrivée(par le client)

  List<Trajet> findByVilleDepartContainingIgnoreCaseAndVilleArriveeContainingIgnoreCase(String VilleDepart,String VilleArrivee);

}
