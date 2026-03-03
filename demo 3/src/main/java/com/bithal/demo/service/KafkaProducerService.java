package com.bithal.demo.service;

import com.bithal.demo.entity.Employee;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

@Service
public class KafkaProducerService {

    @Autowired
    private KafkaTemplate<String, Employee> kafkaTemplate;

    private static final String TOPIC = "employee-topic";

    public void sendMessage(Employee employee) {
        kafkaTemplate.send(TOPIC, String.valueOf(employee.id()), employee);
        System.out.println("Employee sent to Kafka topic: " + employee);
    }

    public void sendMessage(String topic, Employee employee) {
        kafkaTemplate.send(topic, String.valueOf(employee.id()), employee);
        System.out.println("Employee sent to Kafka topic " + topic + ": " + employee);
    }
}
