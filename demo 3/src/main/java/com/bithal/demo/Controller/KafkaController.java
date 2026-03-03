package com.bithal.demo.Controller;

import com.bithal.demo.entity.Employee;
import com.bithal.demo.service.KafkaProducerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/kafka")
public class KafkaController {

    @Autowired
    private KafkaProducerService kafkaProducerService;

    @PostMapping("/publish")
    public ResponseEntity<String> publishMessage(@RequestBody Employee employee) {
        kafkaProducerService.sendMessage(employee);
        return ResponseEntity.ok("Employee message published successfully!");
    }

    @PostMapping("/publish/{topic}")
    public ResponseEntity<String> publishToTopic(@PathVariable String topic, @RequestBody Employee employee) {
        kafkaProducerService.sendMessage(topic, employee);
        return ResponseEntity.ok("Employee message published to topic: " + topic);
    }

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("Kafka integration is healthy!");
    }
}
