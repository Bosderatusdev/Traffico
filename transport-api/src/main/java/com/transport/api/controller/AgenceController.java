package com.transport.api.controller;

import com.transport.api.model.Agence;
import com.transport.api.service.AgenceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/agences")
public class AgenceController {

    @Autowired
    private AgenceService agenceService;

    // GET — Récupérer toutes les agences
    @GetMapping
    public List<Agence> getAllAgences() {
        return agenceService.getAllAgences();
    }

    // GET — Récupérer une agence par ID
    @GetMapping("/{id}")
    public ResponseEntity<Agence> getAgenceById(@PathVariable Long id) {
        return agenceService.getAgenceById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // POST — Créer une agence
    @PostMapping
    public Agence createAgence(@RequestBody Agence agence) {
        return agenceService.createAgence(agence);
    }

    // PUT — Modifier une agence
    @PutMapping("/{id}")
    public ResponseEntity<Agence> updateAgence(@PathVariable Long id, @RequestBody Agence agence) {
        try {
            return ResponseEntity.ok(agenceService.updateAgence(id, agence));
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }

    // DELETE — Supprimer une agence
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteAgence(@PathVariable Long id) {
        agenceService.deleteAgence(id);
        return ResponseEntity.ok().build();
    }
}