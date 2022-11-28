FROM alpine/git:latest
WORKDIR /clone-workspace
RUN git clone https://github.com/ging/practica_big_data_2019

FROM python:3.7

WORKDIR /usr/src/app

COPY --from=0 /clone-workspace/practica_big_data_2019 /usr/src/app/

ENV PROJECT_HOME=/usr/src/app/practica_big_data_2019

RUN pip install --no-cache-dir -r requirements.txt

RUN pip install --no-cache-dir joblib

CMD ["python", "resources/web/predict_flask.py"]