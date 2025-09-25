#!/bin/bash

yum update -y
yum install docker -y
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user
yum install unzip -y

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install


export AWS_DEFAULT_REGION=ap-south-1

aws ecr get-login-password --region ap-south-1 | \
docker login --username AWS --password-stdin 145065858967.dkr.ecr.ap-south-1.amazonaws.com

docker pull 145065858967.dkr.ecr.ap-south-1.amazonaws.com/adarshm/strapi:${image_tag}

docker run -d -p 1337:1337 \
-e APP_KEYS=myKeyA,myKeyB \
-e API_TOKEN_SALT=8QGwDzJ2Pj+ZZD+v4Dpmcw== \
-e TRANSFER_TOKEN_SALT=8QGwDzJ2Pj+ZZD+v4Dpmcw== \
-e ADMIN_JWT_SECRET=ak3wXp25yIi4BdVtROx/AQ== \
145065858967.dkr.ecr.ap-south-1.amazonaws.com/adarshm/strapi:${image_tag}


