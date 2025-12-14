package com.albergue.MiProyecto.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
@RestController
@RequestMapping("/api/donaciones")
@CrossOrigin(origins = "*")
public class DonacionController {

    @Autowired
    private JdbcTemplate jdbc;

    @PostMapping("/registrar")
    public ResponseEntity<String> registrarDonacion(@RequestBody Map<String, Object> datos) {
        String usuario = (String) datos.get("usuario");
        String metodo = (String) datos.get("metodo_pago");
        Double monto = Double.valueOf(datos.get("monto").toString());

        String sql = "INSERT INTO donacion(usuario, metodo_pago, monto) VALUES (?, ?, ?)";
        int result = jdbc.update(sql, usuario, metodo, monto);

        if (result > 0) {
            return ResponseEntity.ok("¡Donación exitosa!");
        } else {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error al registrar donación.");
        }
    }
}
