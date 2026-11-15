package com.transport.api.service;

import com.transport.api.model.Bus;
import com.transport.api.repository.BusRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class BusService {
  @Autowired
  private BusRepository busRepository;

  //récupérer tous les bus
  public List<Bus> getAllBus(){
    return busRepository.findAll();
  }

  //récupérer un bus par ID
  public Optional<Bus> getBusById(Long id){
    return busRepository.findById(id);
  }

  //récupérer les bus d'une agence
  public List<Bus> getBusByAgence(Long AgenceId){
    return busRepository.findByAgenceId(AgenceId);
  }

  //Créer un nouveau bus
  public Bus createBus(Bus bus){
    return busRepository.save(bus);
  }

  //modifier un bus
  public Bus updateBus(Long id, Bus busDetails){
    Bus bus = busRepository.findById(id).orElseThrow();
    bus.setNumero(busDetails.getNumero());
    bus.setCapacite(busDetails.getCapacite());
    bus.setStatut(busDetails.getStatut());
    bus.setType(busDetails.getType());
    return busRepository.save(bus);
  }

  //supprimer un bus
  public void deleteBus(Long id){
    busRepository.deleteById(id);
  }



}
