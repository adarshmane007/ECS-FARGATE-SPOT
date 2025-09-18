#!/bin/bash

# Update and install Docker
yum update -y
yum install docker -y
systemctl start docker
systemctl enable docker

# Add ec2-user to docker group to avoid permission issues
usermod -aG docker ec2-user

# Install unzip before using it
yum install unzip -y

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Set AWS credentials (for ECR access)
export AWS_ACCESS_KEY_ID=AKIAUCAPRPCKEN3XNC3J
export AWS_SECRET_ACCESS_KEY=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
export AWS_DEFAULT_REGION=us-east-1

# Authenticate to ECR
aws ecr get-login-password --region us-east-1 | \
docker login --username AWS --password-stdin 279205476500.dkr.ecr.us-east-1.amazonaws.com

# Pull and run the Strapi container
docker pull 279205476500.dkr.ecr.us-east-1.amazonaws.com/strapi-app:v4

docker run -d -p 1337:1337 \
-e APP_KEYS=myKeyA,myKeyB \
-e API_TOKEN_SALT=8QGwDzJ2Pj+ZZD+v4Dpmcw== \
-e TRANSFER_TOKEN_SALT=8QGwDzJ2Pj+ZZD+v4Dpmcw== \
279205476500.dkr.ecr.us-east-1.amazonaws.com/strapi-app:v4