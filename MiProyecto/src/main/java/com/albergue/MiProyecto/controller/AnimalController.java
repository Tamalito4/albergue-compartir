package com.albergue.MiProyecto.controller;

import com.albergue.MiProyecto.model.Animal;
import com.albergue.MiProyecto.model.Usuario;
import com.albergue.MiProyecto.repository.AnimalRepository;
import com.albergue.MiProyecto.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/animales")
@CrossOrigin(origins = "*")
public class AnimalController {

    @Autowired
    private AnimalRepository animalRepository;

    @Autowired
    private UsuarioRepository usuarioRepository;

    private boolean esAdmin(String usuario) {
        return usuarioRepository.findByUsuario(usuario)
                .map(u -> "ADMIN".equalsIgnoreCase(u.getRol()))
                .orElse(false);
    }

    @PostMapping("/agregar")
    public String agregarAnimal(@RequestBody Animal animal, @RequestParam String usuario) {
        if (!esAdmin(usuario)) return "Acceso denegado";
        animalRepository.save(animal);
        return "Animal agregado exitosamente";
    }

    @PutMapping("/actualizar/{id}")
    public String actualizarAnimal(@PathVariable Long id, @RequestBody Animal animal, @RequestParam String usuario) {
        if (!esAdmin(usuario)) return "Acceso denegado";

        return animalRepository.findById(id).map(existente -> {
            existente.setNombre(animal.getNombre());
            existente.setEspecie(animal.getEspecie());
            existente.setRaza(animal.getRaza());
            existente.setEdad(animal.getEdad());
            animalRepository.save(existente);
            return "Animal actualizado exitosamente";
        }).orElse("Animal no encontrado");
    }

    @DeleteMapping("/eliminar/{id}")
    public String eliminarAnimal(@PathVariable Long id, @RequestParam String usuario) {
        if (!esAdmin(usuario)) return "Acceso denegado";
        if (!animalRepository.existsById(id)) return "Animal no encontrado";
        animalRepository.deleteById(id);
        return "Animal eliminado exitosamente";
    }

    @GetMapping("/listar")
    public List<Animal> listarTodos() {
        return animalRepository.findAll();
    }
}
