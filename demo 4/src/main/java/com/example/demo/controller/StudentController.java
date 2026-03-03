package com.example.demo.controller;

import com.example.demo.service.StudentService;
import com.example.demo.entity.Student;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
public class StudentController {
    @Autowired
    private StudentService studentService;

//     public StudentController(StudentService studentService) {
//        this.studentService = studentService;
//    }
@PostMapping("/students")
     public Student saveStudent(@RequestBody Student student) {
         return studentService.saveStudent(student);
     }

     @GetMapping("/students/{id}")
     public Student getStudentById(@PathVariable int id) {
         return studentService.getStudentById(id);
     }
}
