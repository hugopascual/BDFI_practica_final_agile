#!/bin/bash

# Clean data
rm $PROJECT_HOME/data/origin_dest_distances.jsonl
rm $PROJECT_HOME/data/simple_flight_delay_features.jsonl.bz2

# Clean Zookeeper
rm -rf /tmp/zookeeper

# Clean Kakfa
rm -rf /tmp/kafka-logs

# Clean MongoDB
sudo systemctl start mongod
mongosh agile_data_science --eval 'db.dropDatabase()'
sudo systemctl stop mongod

# Clean predictions models
rm -r $PROJECT_HOME/models
