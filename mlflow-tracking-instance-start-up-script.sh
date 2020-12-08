#!/bin/bash
MLFLOWVERSION=${version}
MLFLOWPASSWD=${password}
MODELSBUCKET=${bucket}

# Install docker
apt-get update
apt-get -yq install apt-transport-https ca-certificates curl gnupg software-properties-common apache2-utils
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
apt-get update
apt-get -yq install docker-ce docker-compose

# Mount persistent disk
# Only first time: DELETE ALL DATA!!!
if [ ! -n "`lsblk -f | grep sdb | grep ext4`" ]; then
    mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb;
fi
mkdir -p /mnt/disks/sdb
mount -o discard,defaults /dev/sdb /mnt/disks/sdb
mkdir /mnt/disks/sdb/mlflow-tracking
chmod a+w /mnt/disks/sdb

cd /root

# MLflow Dockerfile
cat <<EOF > Dockerfile
FROM python:slim
RUN apt-get update && apt-get install -y sqlite
RUN pip install mlflow==1.12.1 google-cloud-storage
EOF

# nginx.conf
cat <<EOF > nginx.conf
events { }
http {
    server {
        location / {
            proxy_pass http://mlflow:5000;
            auth_basic "Restricted";
            auth_basic_user_file /etc/nginx/.htpasswd;
        }
    }
}
EOF

# Docker-compose with nginx authentication
cat <<EOF > docker-compose.yaml
version: '3'
services:
  nginx:
    image: nginx:latest
    container_name: nginx
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./.htpasswd:/etc/nginx/.htpasswd
    ports:
      - 80:80
  mlflow:
    image: mlflow
    container_name: mlflow
    volumes:
      - /mnt/disks/sdb/mlflow-tracking:/mlflow
    expose:
      - "5000"
    entrypoint: ["mlflow", "server", "-h", "0.0.0.0", "-p", "5000", "--backend-store-uri", "sqlite:///mlflow/tracking.db", "--default-artifact-root", "gs://$MODELSBUCKET"]
EOF

#git clone https://github.com/benqua/mlflow-terraform-google-cloud.git
#cd mlflow-terraform-google-cloud/docker
docker build -t mlflow .

# Generate httpd password file
htpasswd -bc .htpasswd mlflow $MLFLOWPASSWD

# Launch the mlflow server with nginx proxy
docker-compose up
