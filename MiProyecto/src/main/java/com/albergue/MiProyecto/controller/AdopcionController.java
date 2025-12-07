package com.albergue.MiProyecto.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.*;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api/adopciones")
@CrossOrigin(origins = "*")
public class AdopcionController {

    @Autowired
    private JdbcTemplate jdbc;

@PostMapping("/solicitar")
public ResponseEntity<String> solicitarAdopcion(@RequestBody Map<String, String> datos) {
    String usuario = datos.get("usuario");
    String nombreAnimal = datos.get("nombre_animal");
    String motivo = datos.get("motivo");

    if (usuario == null || nombreAnimal == null || usuario.isEmpty() || nombreAnimal.isEmpty()) {
        return ResponseEntity.badRequest().body("Datos incompletos para registrar la solicitud.");
    }

    try {
        // Verifica si ya hay solicitud
        String sqlVerificar = "SELECT COUNT(*) FROM adopcion WHERE usuario = ? AND nombre_animal = ? AND estado IN ('pendiente', 'aprobada')";
        Integer count = jdbc.queryForObject(sqlVerificar, Integer.class, usuario, nombreAnimal);

        if (count != null && count > 0) {
            return ResponseEntity.badRequest().body("Ya existe una solicitud en curso para este animal.");
        }

        // Intenta insertar
        String sql = "INSERT INTO adopcion(usuario, nombre_animal, motivo) VALUES (?, ?, ?)";
        int result = jdbc.update(sql, usuario, nombreAnimal, motivo);

        return result > 0
            ? ResponseEntity.ok("Solicitud de adopción registrada.")
            : ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error al registrar solicitud.");
    } catch (Exception e) {
        System.err.println("❌ Error al registrar adopción:");
        e.printStackTrace(); // Esto mostrará el error exacto en tu CMD
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error interno al procesar la solicitud.");
    }
}





    @GetMapping("/pendientes")
    public List<Map<String, Object>> listarPendientes() {
        return jdbc.queryForList("SELECT * FROM adopcion WHERE estado = 'pendiente'");
    }

    @PostMapping("/actualizar-estado")
    public ResponseEntity<String> actualizarEstado(@RequestBody Map<String, String> datos) {
        String usuario = datos.get("usuario");
        String nombreAnimal = datos.get("nombre_animal");
        String estado = datos.get("estado");

        String sql = "UPDATE adopcion SET estado = ? WHERE usuario = ? AND nombre_animal = ?";
        int result = jdbc.update(sql, estado, usuario, nombreAnimal);

        return result > 0
                ? ResponseEntity.ok("Estado actualizado.")
                : ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error al actualizar estado.");
    }

    @GetMapping("/estado/{usuario}")
    public List<Map<String, Object>> obtenerEstados(@PathVariable String usuario) {
        return jdbc.queryForList("SELECT * FROM adopcion WHERE usuario = ?", usuario);
    }

@GetMapping("/todas")
public List<Map<String, Object>> listarTodas() {
    return jdbc.queryForList("SELECT * FROM adopcion ORDER BY fecha DESC");
}

}
