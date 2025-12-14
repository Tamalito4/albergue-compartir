package com.albergue.MiProyecto.repository;

import com.albergue.MiProyecto.model.Animal;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AnimalRepository extends JpaRepository<Animal, Long> {
}
