package com.transport.api.service;

import java.security.SecureRandom;
import java.time.LocalDateTime;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

import com.transport.api.model.User;
import com.transport.api.repository.UserRepository;

@Service
public class VerificationService {
  @Autowired
  private UserRepository userRepository;

  @Autowired
  private JavaMailSender mailSender;

  //Générer un code aléatoire à 6chiffres
  private String generateCode(){
    SecureRandom random = new SecureRandom();
    int code = 100000 + random.nextInt(900000);
    return String.valueOf(code);
  }
  
  //Envoyer le code de vérification email
  public void sendEmailVerification(User user){
    String code = generateCode();
    user.setCodeVerificationEmail(code);
    user.setCodeExpiration(LocalDateTime.now().plusMinutes(10));
    userRepository.save(user);

    SimpleMailMessage message = new SimpleMailMessage();
    message.setTo(user.getEmail());
    message.setSubject("Code de Vérification - Transport");
    message.setText("Votre code de vérification est :"+code+"\nCe code expire dans 10 minutes.");
    mailSender.send(message);


  }

  //Envoyer le code de vérification Téléphone
  public void sendPhoneVerification(User user){
    String code = generateCode();
    user.setCodeVerificationTelephone(code);
    user.setCodeExpiration(LocalDateTime.now().plusMinutes(10));
    userRepository.save(user);


    //Simulation : en attendant un vrai compte SMS ( ex: Twilio )
    System.out.println("============================");
    System.out.println("SMS simulé vers "+user.getTelephone());
    System.out.println("Code de vérification :"+code);
    System.out.println("============================");

  }

  //vérifier le code Email
  public boolean verifyEmailCode(User user,String code){
    if(user.getCodeVerificationEmail() == null) return false;
    if(user.getCodeExpiration().isBefore(LocalDateTime.now())) return false;
    if(!user.getCodeVerificationEmail().equals(code)) return false;

    user.setEmailVerifie(true);
    user.setCodeVerificationEmail(null);
    userRepository.save(user);
    return true;
  }


  //vérifier le code téléphone
  public boolean verifyPhoneCode(User user,String code){
    if(user.getCodeVerificationTelephone() == null) return false;
    if(user.getCodeExpiration().isBefore(LocalDateTime.now())) return false;
    if(!user.getCodeVerificationTelephone().equals(code)) return false;

    user.setTelephoneVerifie(true);
    user.setCodeVerificationTelephone(null);
    userRepository.save(user);
    return true;

  }




  //=== Réinitiarisation du mot de passe === //
  //Envoyer les code de réinitialisation par email

  public void sendPasswordResetEmail(User user){
    String code = generateCode();
    user.setCodeResetPassword(code);
    user.setCodeResetExpiration(LocalDateTime.now().plusMinutes(10));
    userRepository.save(user);

    SimpleMailMessage message = new SimpleMailMessage();
    message.setTo(user.getEmail());
    message.setSubject("Réinitialisation du mot de passe - Transport Burundi");
    message.setText("Votre code de réinitialisation est "+code+" \nCe code expire dans 10 minutes .\nSi vous n'êtes pas à l'origine de cette demande ,ignorez cet email");
    mailSender.send(message);
  }


  //Envoyer le code de réinitialisation par Téléphone(simulé pour l'instant)
  public void sendPasswordResetSms(User user){
    String code = generateCode();
    user.setCodeResetPassword(code);
    user.setCodeResetExpiration(LocalDateTime.now().plusMinutes(10));
    
    userRepository.save(user);


    //  SIMULATION : en attendant un vrai compte SMS
    System.out.println("====================================");
    System.out.println("SMS simulé (reset password) vers "+user.getTelephone());
    System.out.println("Code de réinitialisation : "+code);
    System.out.println("====================================");


  }

  //vérifier le code et retourner true/false (sans modifier le mot de passe ici)
  public boolean verifyResetCode(User user, String code){
    if(user.getCodeResetPassword() == null) return false;
    if(user.getCodeResetExpiration().isBefore(LocalDateTime.now())) return false;
    return user.getCodeResetPassword().equals(code);
}

  //Invalider le code après vérification(sécurité - usage unique)
  public void clearResetCode(User user){
  user.setCodeResetPassword(null);
  user.setCodeResetExpiration(null);

  userRepository.save(user);

  }




  
}
