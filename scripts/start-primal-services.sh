#!/bin/bash
##############################################
# Ejecutar source ../set_env.sh
##############################################
mkdir logs

mkdir $AIRFLOW_HOME
mkdir $AIRFLOW_HOME/dags
mkdir $AIRFLOW_HOME/logs
mkdir $AIRFLOW_HOME/plugins

# Download updated data
resources/download_data.sh

# Instalar librerias de python
pip install -r $PROJECT_HOME/requirements.txt
pip install -r $PROJECT_HOME/resources/airflow/requirements.txt
##############################################
# arrancar Zookeeper, Kafka y crear el topic 'flight_delay_classification_request'

# Arrancar Zookeeper
apache-zookeeper-3.7.1-bin/bin/zkServer.sh start apache-zookeeper-3.7.1-bin/conf/zoo_sample.cfg > logs/zookeeper.txt

# Arrancar kafka
kafka_2.12-3.1.2/bin/kafka-server-start.sh kafka_2.12-3.1.2/config/server.properties > logs/kafka.txt 2>&1 &

# Crear un nuevo topic en otra terminal
kafka_2.12-3.1.2/bin/kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic flight_delay_classification_request
##############################################
# Importar datos a MongoDB
# Arrancar MongoDB
sudo systemctl start mongod

# Importar distancias
$PROJECT_HOME/resources/import_distances.sh
##############################################
# Entrenar y guardar el modelo con PySpark mllib

# Ejecutar script
# Ya que se usa Apache Airflow el entrenamiento se puede ejecutar previo al arranque
# de la aplicacion o posteriormente utilizando el propio DAG de airflow
python3 $PROJECT_HOME/resources/train_spark_mllib_model.py .
##############################################
# Install airflow with pip
pip install -r resources/airflow/requirements.txt
#Create airflow user
airflow users create --username hugo --password 1234 --firstname hugo --lastname pascual --role Admin --email hugopascual998@gmail.com
# Init airflow db
airflow db init
# Install DAG
cp $PROJECT_HOME/resources/airflow/setup.py $PROJECT_HOME/airflow/dags/setup.py
python3 $PROJECT_HOME/airflow/dags/setup.py
##############################################


