#!/bin/bash

echo "Starting Services..."
docker-compose up -d
# Schema registry and superset are slow to start
sleep 30


echo "Creating Topics..."
docker-compose exec kafka1 kafka-topics --bootstrap-server kafka1:9092 --topic customerCases --create --partitions 1
docker-compose exec kafka1 kafka-topics --bootstrap-server kafka1:9092 --topic inventory --create --partitions 1
docker-compose exec kafka1 kafka-topics --bootstrap-server kafka1:9092 --topic transactions --create --partitions 1


echo "Loading Data..."
cat data/customer_cases.avsc | docker-compose exec -T schema-registry tee -a customer_cases.avsc
cat data/inventory.avsc | docker-compose exec -T schema-registry tee -a inventory.avsc
cat data/transactions.avsc | docker-compose exec -T schema-registry tee -a transactions.avsc

cat data/customer_cases.json |
    docker-compose exec -T schema-registry kafka-avro-console-producer \
      --bootstrap-server kafka1:9092 \
      --topic customerCases \
      --property schema.registry.url=http://schema-registry:8081 \
      --property value.schema.file=customer_cases.avsc
cat data/inventory.json |
    docker-compose exec -T schema-registry kafka-avro-console-producer \
      --bootstrap-server kafka1:9092 \
      --topic inventory \
      --property schema.registry.url=http://schema-registry:8081 \
      --property value.schema.file=inventory.avsc
cat data/transactions.json |
    docker-compose exec -T schema-registry kafka-avro-console-producer \
      --bootstrap-server kafka1:9092 \
      --topic transactions \
      --property schema.registry.url=http://schema-registry:8081 \
      --property value.schema.file=transactions.avsc

echo "Environment ready"