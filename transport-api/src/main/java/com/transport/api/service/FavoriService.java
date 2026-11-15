package com.transport.api.service;

import com.transport.api.dto.FavoriRequest;
import com.transport.api.model.Agence;
import com.transport.api.model.Favori;
import com.transport.api.model.User;
import com.transport.api.repository.AgenceRepository;
import com.transport.api.repository.FavoriRepository;
import com.transport.api.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class FavoriService {

    @Autowired
    private FavoriRepository favoriRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private AgenceRepository agenceRepository;

    public Favori ajouter(Long userId, FavoriRequest request) {
        User user = userRepository.findById(userId).orElseThrow();

        if ("agence".equals(request.getType())) {
            if (request.getAgenceId() == null) {
                throw new RuntimeException("agenceId est obligatoire pour un favori de type agence");
            }
            if (favoriRepository.findByUserIdAndAgenceId(userId, request.getAgenceId()).isPresent()) {
                throw new RuntimeException("Cette agence est déjà dans vos favoris");
            }
            Agence agence = agenceRepository.findById(request.getAgenceId())
                    .orElseThrow(() -> new RuntimeException("Agence introuvable"));

            Favori favori = new Favori();
            favori.setUser(user);
            favori.setType("agence");
            favori.setAgence(agence);
            return favoriRepository.save(favori);

        } else if ("trajet".equals(request.getType())) {
            if (request.getVilleDepart() == null || request.getVilleArrivee() == null) {
                throw new RuntimeException("villeDepart et villeArrivee sont obligatoires pour un favori de type trajet");
            }
            if (favoriRepository.findByUserIdAndVilleDepartAndVilleArrivee(
                    userId, request.getVilleDepart(), request.getVilleArrivee()).isPresent()) {
                throw new RuntimeException("Ce trajet est déjà dans vos favoris");
            }

            Favori favori = new Favori();
            favori.setUser(user);
            favori.setType("trajet");
            favori.setVilleDepart(request.getVilleDepart());
            favori.setVilleArrivee(request.getVilleArrivee());
            return favoriRepository.save(favori);
        }

        throw new RuntimeException("Type de favori invalide (agence ou trajet attendu)");
    }

    public List<Favori> getFavorisByUser(Long userId) {
        return favoriRepository.findByUserId(userId);
    }

    public void supprimer(Long id) {
        favoriRepository.deleteById(id);
    }
}