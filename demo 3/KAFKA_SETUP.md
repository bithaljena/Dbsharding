# Kafka Integration Setup Guide

## Overview
This project now includes Apache Kafka integration for asynchronous message processing using the Employee record.

## Prerequisites
- Docker and Docker Compose (recommended for easy Kafka setup)
- Java 17+
- Maven

## Quick Start with Docker

### 1. Start Kafka and Zookeeper using Docker Compose

Create a `docker-compose.yml` file in your project root:

```yaml
version: '3'
services:
  zookeeper:
    image: confluentinc/cp-zookeeper:7.5.0
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
      ZOOKEEPER_TICK_TIME: 2000
    ports:
      - "2181:2181"

  kafka:
    image: confluentinc/cp-kafka:7.5.0
    depends_on:
      - zookeeper
    ports:
      - "9092:9092"
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka:29092,PLAINTEXT_HOST://localhost:9092
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT
      KAFKA_INTER_BROKER_LISTENER_NAME: PLAINTEXT
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
```

Then run:
```bash
docker-compose up -d
```

### 2. Build and Run the Application

```bash
mvn clean install
mvn spring-boot:run
```

## API Endpoints

### 1. Publish Employee Message to Default Topic
```bash
curl -X POST http://localhost:8080/api/kafka/publish \
  -H "Content-Type: application/json" \
  -d '{"id": 1, "Name": "John Doe", "Email": "john@example.com"}'
```

### 2. Publish Employee Message to Custom Topic
```bash
curl -X POST http://localhost:8080/api/kafka/publish/my-custom-topic \
  -H "Content-Type: application/json" \
  -d '{"id": 2, "Name": "Jane Smith", "Email": "jane@example.com"}'
```

### 3. Check Kafka Health
```bash
curl http://localhost:8080/api/kafka/health
```

## How It Works

### Producer (KafkaProducerService)
- Sends Employee records to Kafka topics
- Uses JSON serialization for message content
- Default topic: `employee-topic`

### Consumer (KafkaConsumerService)
- Listens to messages on `employee-topic`
- Two consumer groups for demonstration:
  - `demo-group`: Primary consumer
  - `demo-group-2`: Alternate consumer for parallel processing

### Configuration
All Kafka settings are in `application.properties`:
- Bootstrap servers: `localhost:9092`
- Producer serialization: JSON
- Consumer deserialization: JSON with type mapping

## Creating Kafka Topics

If topics aren't auto-created, use Kafka CLI:

```bash
# Access Kafka container
docker exec -it <kafka-container-id> bash

# Create topic
kafka-topics --create --topic employee-topic --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1

# List topics
kafka-topics --list --bootstrap-server localhost:9092

# Describe topic
kafka-topics --describe --topic employee-topic --bootstrap-server localhost:9092
```

## Monitoring Messages

Using Kafka Console Consumer:

```bash
docker exec -it <kafka-container-id> bash

kafka-console-consumer --bootstrap-server localhost:9092 --topic employee-topic --from-beginning
```

## Project Structure

```
src/main/java/com/bithal/demo/
├── config/
│   └── KafkaConfig.java           # Kafka configuration beans
├── service/
│   ├── KafkaProducerService.java  # Producer logic
│   └── KafkaConsumerService.java  # Consumer logic
└── Controller/
    └── KafkaController.java        # REST endpoints for Kafka
```

## Dependencies Added
- `spring-kafka`: Spring Kafka integration
- Apache Kafka client libraries (auto-included)

## Troubleshooting

1. **Connection refused on localhost:9092**
   - Ensure Kafka is running with `docker-compose ps`
   - Check Docker container logs: `docker-compose logs kafka`

2. **Messages not being consumed**
   - Verify topic exists
   - Check consumer group status with `kafka-consumer-groups`
   - Ensure JSON deserialization is properly configured

3. **Port already in use**
   - Change ports in docker-compose.yml
   - Update `spring.kafka.bootstrap-servers` in application.properties

## Next Steps
- Implement message persistence with database
- Add error handling and retry policies
- Implement topic partitioning strategy
- Add message filtering and transformation
- Integrate with business logic (StudentService, etc.)
