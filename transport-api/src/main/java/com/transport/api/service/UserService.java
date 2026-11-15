package com.transport.api.service;

import com.transport.api.controller.AgenceController;
import com.transport.api.controller.ChauffeurController;
import com.transport.api.model.User;
import com.transport.api.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class UserService {

  private final AgenceController agenceController;

  private final ChauffeurController chauffeurController;

  @Autowired
  private UserRepository userRepository;

  @Autowired
  private  JavaMailSender mailSender;


  UserService(ChauffeurController chauffeurController, AgenceController agenceController) {
    this.chauffeurController = chauffeurController;
    this.agenceController = agenceController;
  }


  //récuperer tous les users

  public List<User> getAllUsers(){
    return userRepository.findAll();
  }

  // récupérer un user by id

  public Optional<User> getUserById(Long id){
    return userRepository.findById(id);
  }

  //récupérer un user par email

  public Optional<User> getUserByEmail(String email){
    return userRepository.findByEmail(email);
  }

  //récupérer un user par telephone

  public Optional<User> findByTelephone(String telephone){
    return userRepository.findByTelephone(telephone);
  }

  //ajouter un nouveau user

  public User createUser(User user){
    return userRepository.save(user);
  }

  //modifier un utilisateur

  public User updateUser(Long id, User userDetails){
    User user = userRepository.findById(id).orElseThrow();
    user.setNom(userDetails.getNom());
    user.setPrenom(userDetails.getPrenom());
    return userRepository.save(user);
  }

  //supprimer un user

  private int genereCodeSuppr(){
    SecureRandom random = new  SecureRandom();

    int code = 10 + random.nextInt(90);
    return code;
  }

  public void deleteUser(Long id){

    User user = userRepository.findById(id).orElseThrow();
    // j'anonimise le compte pour que les agences peuvent avoir les traces , concernant les actions nécessitant ce qui se sont passées les réservations , le calculs argent , etchauffeurController

   
    user.setNom("Compte supprimé");
    user.setPrenom(null);
    user.setEmail(null);
    user.setTelephone("deleted_401R"+genereCodeSuppr()+user.getId());
    user.setMotDePasse(null);
    user.setRole("supprime");
    user.setEmailVerifie(false);
    user.setTelephoneVerifie(false);
    userRepository.save(user);

    
    
  }




  // je veux ajouter des méthodes concernant la modif des infos du comptes

  private String genererCode() {
    return String.valueOf((int) (Math.random() * 900000) + 100000);
}

public void demanderChangementEmail(Long userId, String nouvelEmail) {
    if (userRepository.existsByEmail(nouvelEmail)) {
        throw new RuntimeException("Cet email est déjà utilisé par un autre compte");
    }

    User user = userRepository.findById(userId).orElseThrow();
    String code = genererCode();

    user.setNouvelEmailEnAttente(nouvelEmail);
    user.setCodeChangementEmail(code);
    user.setCodeChangementEmailExpiration(LocalDateTime.now().plusMinutes(10));
    userRepository.save(user);

    // emailService.envoyerCodeChangementEmail(nouvelEmail, code); 

    SimpleMailMessage message = new SimpleMailMessage();
    message.setTo(user.getNouvelEmailEnAttente());
    message.setSubject("Code de Changement Email - Transport");
    message.setText("Votre code de changement Email est :"+code+"\nCe code expire dans 10 minutes.");
    mailSender.send(message);
}

public void confirmerChangementEmail(Long userId, String code) {
    User user = userRepository.findById(userId).orElseThrow();

    if (user.getCodeChangementEmail() == null || !user.getCodeChangementEmail().equals(code)) {
        throw new RuntimeException("Code invalide");
    }
    if (user.getCodeChangementEmailExpiration().isBefore(LocalDateTime.now())) {
        throw new RuntimeException("Code expiré");
    }

    user.setEmail(user.getNouvelEmailEnAttente());
    user.setEmailVerifie(true);
    user.setNouvelEmailEnAttente(null);
    user.setCodeChangementEmail(null);
    user.setCodeChangementEmailExpiration(null);
    userRepository.save(user);
}

public void demanderChangementTelephone(Long userId, String nouveauTelephone) {
    if (userRepository.existsByTelephone(nouveauTelephone)) {
        throw new RuntimeException("Ce téléphone est déjà utilisé par un autre compte");
    }

    User user = userRepository.findById(userId).orElseThrow();
    String code = genererCode();

    user.setNouveauTelephoneEnAttente(nouveauTelephone);
    user.setCodeChangementTelephone(code);
    user.setCodeChangementTelephoneExpiration(LocalDateTime.now().plusMinutes(10));
    userRepository.save(user);

    // Simulation SMS comme le reste du projet — log serveur , je le veux dans un terminal . J'attendrai un abonnement Twilio
    System.out.println("SMS simulé à " + nouveauTelephone + " : code de changement = " + code);
}

public void confirmerChangementTelephone(Long userId, String code) {
    User user = userRepository.findById(userId).orElseThrow();

    if (user.getCodeChangementTelephone() == null || !user.getCodeChangementTelephone().equals(code)) {
        throw new RuntimeException("Code invalide");
    }
    if (user.getCodeChangementTelephoneExpiration().isBefore(LocalDateTime.now())) {
        throw new RuntimeException("Code expiré");
    }

    user.setTelephone(user.getNouveauTelephoneEnAttente());
    user.setTelephoneVerifie(true);
    user.setNouveauTelephoneEnAttente(null);
    user.setCodeChangementTelephone(null);
    user.setCodeChangementTelephoneExpiration(null);
    userRepository.save(user);
}
  




}
