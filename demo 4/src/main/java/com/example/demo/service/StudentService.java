package com.example.demo.service;

import com.example.demo.entity.Student;
import com.example.demo.repository.StudentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class StudentService {

    @Autowired
    private StudentRepository studentRepository;

//    public StudentService(StudentRepository studentRepository) {
//        this.studentRepository = studentRepository;
//    }

    public Student saveStudent(Student student) {
        return studentRepository.save(student);
    }

    public Student getStudentById(int id) {
        return studentRepository.findById(id).orElse(null);
    }
}
