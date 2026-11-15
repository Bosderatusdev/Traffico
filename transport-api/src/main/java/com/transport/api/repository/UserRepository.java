package com.transport.api.repository;

import com.transport.api.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository

public interface UserRepository extends JpaRepository<User, Long>{

  //Trouver un user par email
  Optional<User> findByEmail(String email);

  // Trouver un user par telephone

  Optional<User> findByTelephone(String telephone);

  // Trouver les clients par agenceId qui ont réservé dans une agence
  
  @Query("SELECT DISTINCT r.user FROM Reservation r WHERE r.trajet.agence.id = :agenceId AND r.user.role = 'client'")
  List<User> findClientsByAgenceId(@Param("agenceId") Long agenceId);

  boolean existsByEmail(String email);
  boolean existsByTelephone(String telephone);



  

}