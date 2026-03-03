package com.example.demo.repository;

import com.example.demo.entity.Student;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 * Base repository for Student entity
 * Repositories for different shards can extend this
 */
@Repository
public interface StudentRepository extends JpaRepository<Student, Integer> {
}
