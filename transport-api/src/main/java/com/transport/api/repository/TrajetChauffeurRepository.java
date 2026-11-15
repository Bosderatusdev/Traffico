package com.transport.api.repository;

import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import com.transport.api.model.Trajet;
import com.transport.api.model.TrajetChauffeur;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;

public interface TrajetChauffeurRepository extends JpaRepository<TrajetChauffeur, Long> {

  List<TrajetChauffeur> findByTrajetId(Long trajetId);

  List<TrajetChauffeur> findByChauffeurId(Long chauffeurId);

  Optional<TrajetChauffeur> findByTrajetIdAndChauffeurId(Long trajetId, Long chauffeurId);

  boolean existsByTrajetIdAndChauffeurId(Long trajetId, Long chauffeurId);

  // Utilisée par le scan QR (§2) : vérifie qu'un chauffeur (via son user_id, cf.
  // migration §01)


  @Query("""
        SELECT COUNT(tc) > 0 FROM TrajetChauffeur tc
        WHERE tc.trajet.id = :trajetId
        AND tc.chauffeur.user.id = :userId
    """)
boolean existsByTrajetIdAndChauffeurUserId(@Param("trajetId") Long trajetId,
    @Param("userId") Long userId);

@Query("""
        SELECT tc.trajet FROM TrajetChauffeur tc
        WHERE tc.chauffeur.user.id = :userId
        AND FUNCTION('DATE', tc.trajet.heureDepart) = CURRENT_DATE
        ORDER BY tc.trajet.heureDepart ASC
    """)
List<Trajet> findTrajetsDuJourByChauffeurUserId(@Param("userId") Long userId);


  

  

}
