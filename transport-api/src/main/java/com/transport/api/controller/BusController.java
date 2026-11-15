package com.transport.api.controller;

import com.transport.api.model.Bus;
import com.transport.api.service.BusService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/bus")
public class BusController {
  @Autowired
  private BusService busService;

  //GET - récupérer tous les bus
  @GetMapping
  public List<Bus> getAllBus(){
    return busService.getAllBus();
  }

  //GET - récupérer un bus par ID
  @GetMapping("/{id}")
  public ResponseEntity<Bus> getBusById(@PathVariable Long id){
    return busService.getBusById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
  }

  //GET - récupérer tous les bus d'une agence
  @GetMapping("/agence/{agenceId}")
  public List<Bus> getBusByAgence(@PathVariable Long agenceId){
    return busService.getBusByAgence(agenceId);
  }

  //POST - créer un bus
  @PostMapping
  public Bus createBus(@RequestBody Bus bus){
    return busService.createBus(bus);
  }

  //PUT - modifier un bus
  @PutMapping("/{id}")
  public ResponseEntity<Bus> updateBus(@PathVariable Long id,@RequestBody Bus bus){
    try{
      return ResponseEntity.ok(busService.updateBus(id, bus));
    }catch(Exception e){
      return ResponseEntity.notFound().build();
    }
  }

  //DELETE 6 supprimer un bus
  @DeleteMapping("/{id}")
  public ResponseEntity<Bus> deleteBus(@PathVariable Long id){
    busService.deleteBus(id);
    return ResponseEntity.ok().build();
  }


  
}
