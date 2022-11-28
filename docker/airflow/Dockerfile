FROM apache/airflow:2.1.4-python3.7

COPY ../../practica_big_data_2019/requirements.txt /
RUN pip install --no-cache-dir -r /requirements.txt

COPY ../../practica_big_data_2019/resources/airflow/setup.py /opt/airflow/