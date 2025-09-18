#!/bin/bash
sudo apt update -y
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker

# Authenticate to ECR
aws ecr get-login-password --region us-east-1 | \
docker login --username AWS --password-stdin 279205476500.dkr.ecr.us-east-1.amazonaws.com

# Pull and run the Strapi container
docker pull 279205476500.dkr.ecr.us-east-1.amazonaws.com/strapi-app:v1
docker run -d -p 80:1337 279205476500.dkr.ecr.us-east-1.amazonaws.com/strapi-app:v1
