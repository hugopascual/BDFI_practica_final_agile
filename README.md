# Escenario de la Practica
El Github con el enunciado de la práctica se puede encontrar en el siguiente repositorio:
https://github.com/ging/practica_big_data_2019

## Instalación de componentes
Ir al directorio del proyecto de github y ejecutar la instalación
```
cd practica_big_data_2019
sudo sh ../installations.sh
```
----------------------
## Inicio del escenario con scripts

Para instalar y ejecutar la práctica, se pueden utilizar los scripts de python añadidos a dicha carpeta, donde ahora veremos la funcionalidad de cada uno de ellos:

### 1.- Installations.sh

Realiza la instalación de todos los componentes necesarios para realizar la práctica, con las versiones definidas en el apartado instalación con los correspondientes comandos mencionados. Si no se ha realizado la instalación de las aplicaciones mencionadas, no se puede inicializar la práctica.

### 2.- Environment.sh

Realiza la configuracion de variables de entorno necesarias en el repositorio. Realiza la expertación de todas ellas para un funcionamiento correcto en todos los terminales necesarios y especifica los pasos necesarios para ejecutar la práctica. En todos los terminales que se utilicen en la práctica, se tiene que ejecutar previamente este script.

### 3.- Start-primal-services.sh

Con dicho script comenzamos con la descarga de datos de la práctica, rellenando los datos de vuelos de diferentes años para disponer de la información para nuestra base de datos.
Posteriormente el comando corre los scripts de Zookeper y Kafka para arracncarlos, y crea el topic 'flight_delay_classification_request'.

Inicializa la base de datos en MongoDB e importa en ella las distancias.
Posteriormente realiza el entrenamiento del modelo a través de PySpark mllib y almacena el modelo en la base de datos.

Por último crea un usuario airflow por defecto con el nombre de uno de los alumnos que realizarón la práctica y una contraseña e inicializa la base de datos en airflow. Finalmente instala el DAG de datos necesarios para el uso de Apache Airflow.

### 4.- Spark-app.sh

Arranca la aplicación de predicción de vuelos 'Flight Predicator' a través de spark submit y con los datos almacenados en mongo. Requiere que estén instalados todos los componentes para un correcto funcionamiento del comando. Se usa en vez de utilizar intellIJ para realizar las predicciones y lanzar la aplicacion. (Mejora 1).

### 5.- Flask.sh

Arranca la aplicación de flask para visualizar la predicción de nuevos vuelos introduccidos por el usuario. Se puede observar a través del puerto 5000 de localhost en un navegador.

### 6.- Airflow-web.sh 

Arranca Airflow para tener acceso desde el puerto 3000 de localhost.

### 7.- Airflow-scheduler.sh

Arranca Airflow Scheduler para su uso.

### 8.- Stop-primal-services.sh
Este comando pone fin a la práctica y sirve para parar todos los recursos lanzados en el terminal con start-primal-services.sh. Pausa y elimina los procesos de Kafka, Mongo y Zookeper.


# Inicio del escenario manual
## Descarga de datos base

Ejecutamos el siguiente Script, donde se incluyen los comandos necesarios para realizar la instalación de todas las versiones necesarias

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

## Crear un nuevo topic en otra terminal
```
kafka_2.12-3.1.2/bin/kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic flight_delay_classification_request
```
Deberia salir un mensaje como:
```
Created topic "flight_delay_classification_request".
```
Se puede consultar la lista de topics con:
```
kafka_2.12-3.1.2/bin/kafka-topics.sh --bootstrap-server localhost:9092 --list
```
Se puede abrir una consola con un consumidor para ver los mensajes que llegan al topic
```
kafka_2.12-3.1.2/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic flight_delay_classification_request --from-beginning
```

## Importar datos a MongoDB

Arrancar Mongo y comprobar que esta en funcionamiento
```
sudo systemctl start mongod
sudo systemctl status mongod

Run import_distances.sh
```
Ojo, aquí se sufre una modificación debido al uso de un comando obsoleto, por ello se utiliza la llamada mongosh en vez de mongo dentro de import_distances.sh.
!!!! No funciona de serie hay que cambiar "mongo" por "mongosh"
./resources/import_distances.sh

## Entrenar y guardar el modelo con PySpark mllib

Primero Seteamos JAVA_HOME
```
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
```
Como ejecutar el script 
```
python3 resources/train_spark_mllib_model.py .
```
Los resultados deberían estar guardados en /models
```
ls /models
```
## Arrancar la aplicación Flight Predicator

Se puede hacer a traves de IntellIJ arrancado el main de MakePrediction

Otra forma es compilar con sbt el MakePrediction.scala y arrancarlo con spark-submit
Para compilar el proyecto, abrir un terminal en el directorio donde se encuentra el src del proyecto
Ejecutar sbt y en la shell de sbt ejecutar el compile
```
sbt
# En la bash abierta por el anterior comando
compile
# El resultado de la compilación debería resultar en
practica_big_data_2019/flight_prediction/target/scala-2.12/classes ...
# Tras la compilación creamos el .jar utilizando el siguiente comando en la bash de sbt
package
# El resultado de la compilación estará en target/scala-2.12/
```
```
# Una vez tengamos el .jar para lanzar el servicio utilizamos
spark-submit --packages org.mongodb.spark:mongo-spark-connector_2.12:3.0.1,org.apache.spark:spark-sql-kafka-0-10_2.12:3.1.2 flight_prediction/target/scala-2.12/flight_prediction_2.12-0.1.jar
```

# Start the prediction request Web Application

Crear la variable de entorno al repositorio clonado 
```
export PROJECT_HOME=/home/hugo/Documentos/BDFI/FinalParte1/practica_big_data_2019
```
Arrancar la aplicación de flask 
```
python3 resources/web/predict_flask.py
# !!!! Libreía del python, "joblib" no encontrada. Hay que comentarla
# Una vez arrancada se debe poder visitar la dirección
# http://localhost:5000/flights/delays/predict_kafka
```
Solo para ver que pasa se puede ejecutar las siguientes instrucciones 
```
open the JavaScript console. Enter a nonzero departure delay, an ISO-formatted date (I used 2016-12-25, which was in the future at the time I was writing this), a valid carrier code (use AA or DL if you don’t know one), an origin and destination (my favorite is ATL → SFO), and a valid flight number (e.g., 1519), and hit Submit. Watch the debug output in the JavaScript console as the client polls for data from the response endpoint at /flights/delays/predict/classify_realtime/response/.
```
Al hacer esto en la consola donde este ejecutando el Spark deberían aparecer trazas nuevas.

# Check the predictions records inserted in MongoDB

Comprobar resultados almacenados en MongoDB
mongosh
En la shell de mongosh ejecutar
```
# !!!! El comando suyo no funciona, hay que quitar el use
use agile_data_science;
db.flight_delay_classification_response.find();
```

## Entrenar el modelo con Apache Airflow

Apache Airflow 2.1.4 se instala con pip. Se usará SQLite para probar en esta práctica aunque no es 
recomendable para producción
PAra instalar las librerías de Apache Airflow:
```
pip install -r resources/requirements.txt -c resources/constraints.txt
```
Para configurar el entorno de Apache Airflow:
```
export AIRFLOW_HOME=~/airflow
mkdir $AIRFLOW_HOME/dags
mkdir $AIRFLOW_HOME/logs
mkdir $AIRFLOW_HOME/plugins

airflow users create --username hugo --password 1234 --firstname hugo --lastname pascual --role Admin --email hugopascual998@gmail.com
```
Arrancar airflow scheduler y webserver:
```
airflow webserver --port 8080
airflow scheduler

# Versión web en la siguiente dirección:
# http://localhost:8080/home
```

The DAG is defined in resources/airflow/setup.py.
TODO: add the DAG and execute it to train the model (see the official documentation of Apache Airflow to learn how to exectue and add a DAG with the airflow command).
TODO: explain the architecture of apache airflow (see the official documentation of Apache Airflow).
TODO: analyzing the setup.py: what happens if the task fails?, what is the peridocity of the task?

## Para ejecutar el DAG desde el terminal
```
airflow tasks test agile_data_science_batch_prediction_model_training pyspark_train_classifier_model 2022-11-22
```

## Despliegue del escenario en Docker
Por último, se puede observar los avances y comandos a ejecutar para realizar el despliegue en docker. Por falta de tiempo únicamente se ha podido probar el funcionamiento de los contenedores y ajustarlos al uso deseado. Debido a los problemas encontrados, no se ha podido realizar un despliegue entero en docker. Los avances se puede encontrar en el docker-compose y en cada uno de los contenedores establecidos.

Para desplegarlo en docker, realizamos la sigguiente configuración:
```
sudo docker-compose down && sudo docker volume prune -f
sudo docker system prune -fa
```
```
sudo docker-compose up -d && sudo docker-compose ps
sudo docker exec -it mongo-db /bin/bash
sudo docker exec -it kafka /bin/bash
sudo docker exec -it spark-master /bin/bash
```
```
sudo docker build -t hugopascual/mongo-bdfi .
sudo docker push hugopascual/mongo-bdfi
```
```
pip install --no-cache-dir -r requirements.txt
python3 resources/train_spark_mllib_model.py .
spark-submit --packages org.mongodb.spark:mongo-spark-connector_2.12:3.0.1,org.apache.spark:spark-sql-kafka-0-10_2.12:3.1.2 /opt/bitnami/spark/jars/flight_prediction_2.12-0.1.jar
 ```
 
 






















