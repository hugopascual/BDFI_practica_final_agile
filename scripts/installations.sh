#!/bin/bash
# Github de la practica
# https://github.com/ging/practica_big_data_2019

# Instalación de componentes

sudo apt update && sudo apt upgrade -y
sudo apt install wget curl gnupg2 software-properties-common apt-transport-https ca-certificates lsb-release

# IntellIJ Idea Community con jdk 1.8
# Referencias
# https://docs.scala-lang.org/getting-started/intellij-track/getting-started-with-scala-in-intellij.html
# https://www.jetbrains.com/idea/download/#section=linux

sudo apt install -y openjdk-8-jdk-headless
sudo snap install intellij-idea-community --classic

# Python3 y Pip
sudo apt-get install -y python3 python3-pip

# SBT
# https://www.scala-sbt.org/release/docs/Installing-sbt-on-Linux.html
# Se puede considerar usar SDKMAN para instalar software de desarrollo
# https://sdkman.io/
sudo apt-get install apt-transport-https curl gnupg -yqq
echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | sudo tee /etc/apt/sources.list.d/sbt.list
echo "deb https://repo.scala-sbt.org/scalasbt/debian /" | sudo tee /etc/apt/sources.list.d/sbt_old.list
curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | sudo -H gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/scalasbt-release.gpg --import
sudo chmod 644 /etc/apt/trusted.gpg.d/scalasbt-release.gpg
sudo apt-get update
sudo apt-get install sbt

# MongoDB
# https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-ubuntu/
wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
sudo apt-get update
# MongoDB no esta soportado oficialmente en ubuntu 22.04 y hay que instalar este paquete para 
# que sea posible compatibilizarlo
# Comentar si se usa ubuntu 20.04
wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb
sudo dpkg -i ./libssl1.1_1.1.1f-1ubuntu2_amd64.deb
rm libssl1.1_1.1.1f-1ubuntu2_amd64.deb

sudo apt-get install -y mongodb-org

# Scala
# https://www.scala-lang.org/download/
# https://www.scala-lang.org/download/2.12.17.html
wget https://downloads.lightbend.com/scala/2.12.17/scala-2.12.17.deb
sudo dpkg -i ./scala-2.12.17.deb
rm scala-2.12.17.deb

# Spark
# https://spark.apache.org/docs/latest/
# https://spark.apache.org/downloads.html
# https://archive.apache.org/dist/spark/
# https://www.tecmint.com/install-apache-spark-on-ubuntu/
wget https://archive.apache.org/dist/spark/spark-3.1.2/spark-3.1.2-bin-hadoop3.2.tgz
tar -xvzf spark-3.1.2-bin-hadoop3.2.tgz
rm spark-3.1.2-bin-hadoop3.2.tgz
sudo mv spark-3.1.2-bin-hadoop3.2 /opt/spark
echo 'export SPARK_HOME=/opt/spark' >> ~/.profile
echo 'export PATH=$PATH:/opt/spark/bin' >> ~/.profile
echo 'export PYSPARK_PYTHON=/usr/bin/python3' >> ~/.profile
source ~/.profile

# Arrancar maestros o esclavos
# start-master.sh
# start-workers.sh spark://localhost:7077
# Acceder a la shell
# spark-shell

# Zookeeper
# https://zookeeper.apache.org/releases.html#download
wget https://dlcdn.apache.org/zookeeper/zookeeper-3.7.1/apache-zookeeper-3.7.1-bin.tar.gz
tar -xvzf apache-zookeeper-3.7.1-bin.tar.gz
rm apache-zookeeper-3.7.1-bin.tar.gz

# Kafka
# https://kafka.apache.org/quickstart
# https://downloads.apache.org/kafka/
wget https://downloads.apache.org/kafka/3.0.2/kafka_2.12-3.1.2.tgz
tar -xvzf kafka_2.12-3.1.2.tgz
rm kafka_2.12-3.1.2.tgz
