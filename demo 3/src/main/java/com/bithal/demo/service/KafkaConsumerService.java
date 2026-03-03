package com.bithal.demo.service;

import com.bithal.demo.entity.Employee;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Service
public class KafkaConsumerService {

    @KafkaListener(topics = "employee-topic", groupId = "demo-group")
    public void consume(Employee employee) {
        System.out.println("Consumed Employee message: " + employee);
        // You can process the employee message here
        // For example, save to database, send notification, etc.
    }

    @KafkaListener(topics = "employee-topic", groupId = "demo-group-2")
    public void consumeAlternate(Employee employee) {
        System.out.println("Alternate Consumer received Employee: " + employee);
    }
}
