#!/bin/bash

sudo docker compose down --remove-orphans && sudo docker volume prune -f
sudo docker compose up -d