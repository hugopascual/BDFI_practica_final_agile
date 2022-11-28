#!/bin/bash

# Parar Zookeeper
$PROJECT_HOME/apache-zookeeper-3.7.1-bin/bin/zkServer.sh stop $PROJECT_HOME/apache-zookeeper-3.7.1-bin/conf/zoo_sample.cfg

# Parar kafka
$PROJECT_HOME/kafka_2.12-3.1.2/bin/kafka-server-stop.sh $PROJECT_HOME/kafka_2.12-3.1.2/config/server.properties

# Para MongoDB
sudo systemctl stop mongod


