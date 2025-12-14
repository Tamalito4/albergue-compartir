package com.albergue.MiProyecto.controller;

import com.albergue.MiProyecto.model.Usuario;
import com.albergue.MiProyecto.repository.UsuarioRepository;
import java.time.LocalDate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;


import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/usuarios")
@CrossOrigin(origins = "*")
public class UsuarioController {

    @Autowired
    private UsuarioRepository usuarioRepo;

    @PostMapping("/registro")
    public Map<String, Object> registrar(@RequestBody Usuario usuario) {
        Map<String, Object> response = new HashMap<>();

        if (usuarioRepo.findByUsuario(usuario.getUsuario()).isPresent()) {
            response.put("status", "error");
            response.put("message", "El usuario ya existe.");
            return response;
        }

        usuario.setRol("USER"); // Por defecto
        usuarioRepo.save(usuario);

        response.put("status", "ok");
        response.put("message", "Registro exitoso.");
        return response;
    }

    @PostMapping("/login")
    public Map<String, Object> login(@RequestBody Map<String, String> datos) {
        String usuario = datos.get("usuario");
        String contrasena = datos.get("contrasena");
        Map<String, Object> response = new HashMap<>();

        return usuarioRepo.findByUsuarioAndContrasena(usuario, contrasena)
                .map(u -> {
                    response.put("status", "ok");
                    response.put("rol", u.getRol());
                    response.put("message", "Inicio de sesión exitoso.");
                    return response;
                })
                .orElseGet(() -> {
                    response.put("status", "error");
                    response.put("message", "Credenciales incorrectas.");
                    return response;
                });
    }
@GetMapping("/listar")
public List<Usuario> listarUsuarios() {
    return usuarioRepo.findAll()
            .stream()
            .filter(u -> !"ADMIN".equals(u.getRol()))
            .collect(Collectors.toList());
}

@PutMapping("/actualizar/{id}")
public ResponseEntity<String> actualizarUsuario(@PathVariable Long id, @RequestBody Map<String, String> datos) {
    return usuarioRepo.findById(id).map(u -> {
        u.setUsuario(datos.get("usuario"));
        u.setCorreo(datos.get("correo"));
        u.setRol(datos.get("rol"));
        usuarioRepo.save(u);
        return ResponseEntity.ok("Usuario actualizado.");
    }).orElse(ResponseEntity.notFound().build());
}

@DeleteMapping("/eliminar/{id}")
public ResponseEntity<String> eliminarUsuario(@PathVariable Long id) {
    return usuarioRepo.findById(id).map(u -> {
        if ("ADMIN".equals(u.getRol())) {
            return ResponseEntity.badRequest().body("No se puede eliminar un administrador.");
        }
        usuarioRepo.deleteById(id);
        return ResponseEntity.ok("Usuario eliminado.");
    }).orElse(ResponseEntity.notFound().build());
}
@GetMapping("/{usuario}")
public ResponseEntity<Usuario> obtenerUsuario(@PathVariable String usuario) {
    return usuarioRepo.findByUsuario(usuario)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
}

@PutMapping("/cambiar-contrasena/{usuario}")
public ResponseEntity<String> cambiarContrasena(@PathVariable String usuario, @RequestBody Map<String, String> datos) {
    String actual = datos.get("actual");
    String nueva = datos.get("nueva");

    Optional<Usuario> optionalUsuario = usuarioRepo.findByUsuario(usuario);

    if (optionalUsuario.isPresent()) {
        Usuario u = optionalUsuario.get();
        if (!u.getContrasena().equals(actual)) {
            return ResponseEntity.badRequest().body("La contraseña actual no coincide.");
        }

        u.setContrasena(nueva);
        usuarioRepo.save(u);  // Aquí se dispara el trigger en la base de datos

        return ResponseEntity.ok("Contraseña actualizada.");
    }

    return ResponseEntity.notFound().build();
}

@PutMapping("/actualizar-por-usuario/{usuario}")
public ResponseEntity<String> actualizarPorUsuario(@PathVariable String usuario, @RequestBody Map<String, String> datos) {
    return usuarioRepo.findByUsuario(usuario).map(u -> {
        u.setNombreCompleto(datos.get("nombreCompleto"));
        u.setCorreo(datos.get("correo"));
        u.setTelefono(datos.get("telefono"));
        u.setLugarNacimiento(datos.get("lugarNacimiento"));

        try {
            String fechaTexto = datos.get("fechaNacimiento");
            if (fechaTexto != null && !fechaTexto.isEmpty()) {
                u.setFechaNacimiento(LocalDate.parse(fechaTexto));
            }
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Fecha de nacimiento inválida.");
        }

        usuarioRepo.save(u);
        return ResponseEntity.ok("Datos actualizados correctamente.");
    }).orElse(ResponseEntity.notFound().build());
}

}
