# Github enunciado de la práctica
https://github.com/ging/practica_big_data_2019

## Instalación de componentes
Ir al directorio del proyecto de github y ejecutar la instalación
```
cd practica_big_data_2019
sudo sh ../installations.sh
```
----------------------
# Inicio del escenario con scripts

----------------------
# Inicio del escenario manual
## Descarga de datos base
```
resources/download_data.sh
```
## Arrancar Zookeeper y Kafka
Instalar librerias de python
```
pip install -r requirements.txt
```
Arrancar Zookeeper
```
apache-zookeep-3.7.1-bin/bin/zkServer.sh start apache-zookeeper-3.7.1-bin/conf/zoo_sample.cfg
``` 
Zookeeper se puede parar con
```
apache-zookeeper-3.7.1-bin/bin/zkServer.sh stop apache-zookeeper-3.7.1-bin/conf/zoo_sample.cfg
```
Arrancar Kafka
```
kafka_2.12-3.1.2/bin/kafka-server-start.sh kafka_2.12-3.1.2/config/server.properties
```
# Crear un nuevo topic en otra terminal
kafka_2.12-3.1.2/bin/kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic flight_delay_classification_request
# Deberia salir un mensaje como:
# Created topic "flight_delay_classification_request".
# Se puede consultar la lista de topics con:
kafka_2.12-3.1.2/bin/kafka-topics.sh --bootstrap-server localhost:9092 --list

# Se puede abrir una consola con un consumidor para ver los mensajes que llegan al topic
kafka_2.12-3.1.2/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic flight_delay_classification_request --from-beginning
------------------------------------------------------------
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
------------------------------------------------------------
# Importar datos a MongoDB

# Arrancar Mongo y comprobar que esta en funcionamiento
sudo systemctl start mongod
sudo systemctl status mongod

# Run import_distances.sh
# !!!! No funciona de serie hay que cambiar "mongo" por "mongosh"
./resources/import_distances.sh
------------------------------------------------------------
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
------------------------------------------------------------
# Entrenar y guardar el modelo con PySpark mllib

# Setear JAVA_HOME
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64

# Ejecutar script 
python3 resources/train_spark_mllib_model.py .

# Los resultados deberían estar guardados en /models
ls /models
------------------------------------------------------------
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
------------------------------------------------------------
# Arrancar la aplicación Flight Predicator

# Se puede hacer a traves de IntellIJ arrancado el main de MakePrediction

# Otra forma es compilar con sbt el MakePrediction.scala y arrancarlo con spark-submit
# Para compilar el proyecto, abrir un terminal en el directorio donde se encuentra el src del proyecto
# Ejecutar sbt y en la shell de sbt ejecutar el compile
sbt
# En la bash abierta por el anterior comando
compile
# El resultado de la compilación debería resultar en
practica_big_data_2019/flight_prediction/target/scala-2.12/classes ...
# Tras la compilación creamos el .jar utilizando el siguiente comando en la bash de sbt
package
# El resultado de la compilación estará en target/scala-2.12/

# Una vez tengamos el .jar para lanzar el servicio utilizamos
spark-submit --packages org.mongodb.spark:mongo-spark-connector_2.12:3.0.1,org.apache.spark:spark-sql-kafka-0-10_2.12:3.1.2 flight_prediction/target/scala-2.12/flight_prediction_2.12-0.1.jar
------------------------------------------------------------
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
------------------------------------------------------------
# Start the prediction request Web Application

# Crear la variable de entorno al repositorio clonado 
export PROJECT_HOME=/home/hugo/Documentos/BDFI/FinalParte1/practica_big_data_2019

# Arrancar la aplicación de flask 
python3 resources/web/predict_flask.py
# !!!! Libreía del python, "joblib" no encontrada. Hay que comentarla
# Una vez arrancada se debe poder visitar la dirección
# http://localhost:5000/flights/delays/predict_kafka

# Solo para ver que pasa se puede ejecutar las siguientes instrucciones 

open the JavaScript console. Enter a nonzero departure delay, an ISO-formatted date (I used 2016-12-25, which was in the future at the time I was writing this), a valid carrier code (use AA or DL if you don’t know one), an origin and destination (my favorite is ATL → SFO), and a valid flight number (e.g., 1519), and hit Submit. Watch the debug output in the JavaScript console as the client polls for data from the response endpoint at /flights/delays/predict/classify_realtime/response/.

# Al hacer esto en la consola donde este ejecutando el Spark deberían aparecer trazas nuevas.
------------------------------------------------------------
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
------------------------------------------------------------
# Check the predictions records inserted in MongoDB

# Comprobar resultados almacenados en MongoDB
mongosh
# en la shell de mongosh
# !!!! El comando suyo no funciona, hay que quitar el use
use agile_data_science;
db.flight_delay_classification_response.find();
------------------------------------------------------------
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
------------------------------------------------------------
# !!!! No realizado
# Entrenar el modelo con Apache Airflow

# Apache Airflow 2.1.4 instalar con pip. Se usará SQLite para probar en esta práctica aunque no es 
# recomendable para producción
# Instalar las librerías de Apache Airflow
pip install -r resources/requirements.txt -c resources/constraints.txt

# Configurar el entorno de Apache Airflow
export AIRFLOW_HOME=~/airflow
mkdir $AIRFLOW_HOME/dags
mkdir $AIRFLOW_HOME/logs
mkdir $AIRFLOW_HOME/plugins

airflow users create --username hugo --password 1234 --firstname hugo --lastname pascual --role Admin --email hugopascual998@gmail.com

# Arrancar airflow scheduler y webserver
airflow webserver --port 8080
airflow scheduler

# Versión web en la siguiente dirección:
# http://localhost:8080/home


The DAG is defined in resources/airflow/setup.py.
TODO: add the DAG and execute it to train the model (see the official documentation of Apache Airflow to learn how to exectue and add a DAG with the airflow command).
TODO: explain the architecture of apache airflow (see the official documentation of Apache Airflow).
TODO: analyzing the setup.py: what happens if the task fails?, what is the peridocity of the task?

# Para ejecutar el DAG desde el terminal
airflow tasks test agile_data_science_batch_prediction_model_training pyspark_train_classifier_model 2022-11-22
------------------------------------------------------------
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
------------------------------------------------------------
sudo docker-compose down && sudo docker volume prune -f
sudo docker system prune -fa

sudo docker-compose up -d && sudo docker-compose ps
sudo docker exec -it mongo-db /bin/bash
sudo docker exec -it kafka /bin/bash
sudo docker exec -it spark-master /bin/bash

sudo docker build -t hugopascual/mongo-bdfi .
sudo docker push hugopascual/mongo-bdfi


pip install --no-cache-dir -r requirements.txt
python3 resources/train_spark_mllib_model.py .
spark-submit --packages org.mongodb.spark:mongo-spark-connector_2.12:3.0.1,org.apache.spark:spark-sql-kafka-0-10_2.12:3.1.2 /opt/bitnami/spark/jars/flight_prediction_2.12-0.1.jar
 






















