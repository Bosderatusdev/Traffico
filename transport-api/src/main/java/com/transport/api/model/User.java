package com.transport.api.model;
import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Entity
@Table(name = "users")
@Data

public class User {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @Column(nullable = false)
  private String nom;

  private String prenom;

  @Column(unique = true)
  private String email;

  @Column(unique=true,nullable = false)
  private String telephone;

  @com.fasterxml.jackson.annotation.JsonIgnore
  private String motDePasse;

  private String role="client";

  @ManyToOne
  @JoinColumn(name = "agence_id")
  private Agence agence;


  @Column(name = "email_verifie")
  private Boolean emailVerifie =false;

  @Column(name = "telephone_verifie")
  private Boolean telephoneVerifie = false;

  @Column(name = "code_verification_email")
  private String codeVerificationEmail;

  @Column(name = "code_verification_telephone")
  private String codeVerificationTelephone;

  @Column(name = "code_Expiration")
  private LocalDateTime codeExpiration;

  @Column(name = "created_at")
  private LocalDateTime createdAt = LocalDateTime.now();

  @Column(name = "code_reset_password")
  private String codeResetPassword;

  @Column(name = "code_reset_expiration")
  private LocalDateTime codeResetExpiration;

  @Column(name = "token_version")
  private  Integer tokenVersion = 1;

  @Column(name = "nouvel_email_en_attente")
  private String nouvelEmailEnAttente;

  @Column(name = "code_changement_email")
  private String codeChangementEmail;

  @Column(name = "code_changement_email_expiration")
  private LocalDateTime codeChangementEmailExpiration;

  @Column(name = "nouveau_telephone_en_attente")
  private String nouveauTelephoneEnAttente;

  @Column(name = "code_changement_telephone")
  private String codeChangementTelephone;

  @Column(name = "code_changement_telephone_expiration")
  private LocalDateTime codeChangementTelephoneExpiration;

  

}
