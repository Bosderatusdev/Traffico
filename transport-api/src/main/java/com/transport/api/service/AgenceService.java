package com.transport.api.service;

import com.transport.api.model.Agence;
import com.transport.api.repository.AgenceRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class AgenceService {

    @Autowired
    private AgenceRepository agenceRepository;

    // Récupérer toutes les agences
    public List<Agence> getAllAgences() {
        return agenceRepository.findAll();
    }

    // Récupérer une agence par ID
    public Optional<Agence> getAgenceById(Long id) {
        return agenceRepository.findById(id);
    }

    // Créer une nouvelle agence
    public Agence createAgence(Agence agence) {
        return agenceRepository.save(agence);
    }

    // Modifier une agence
    public Agence updateAgence(Long id, Agence agenceDetails) {
        Agence agence = agenceRepository.findById(id).orElseThrow();
        agence.setNom(agenceDetails.getNom());
        agence.setTelephone(agenceDetails.getTelephone());
        agence.setEmail(agenceDetails.getEmail());
        agence.setStatut(agenceDetails.getStatut());
        agence.setCommission(agenceDetails.getCommission());
        return agenceRepository.save(agence);
    }

    // Supprimer une agence
    public void deleteAgence(Long id) {
        agenceRepository.deleteById(id);
    }
}