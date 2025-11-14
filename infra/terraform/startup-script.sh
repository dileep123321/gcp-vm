#!/bin/bash
set -e

LOGFILE=/var/log/startup-script.log
exec > >(tee -a \${LOGFILE}) 2>&1

echo "Startup script started at \$(date)"

# Install docker
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

# Install google-cloud-sdk (for gcloud auth configure-docker)
if ! command -v gcloud >/dev/null 2>&1; then
  apt-get install -y gnupg
  echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" \
    > /etc/apt/sources.list.d/google-cloud-sdk.list
  curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
  apt-get update && apt-get install -y google-cloud-sdk
fi

# Read metadata
CONTAINER_IMAGE=$(curl -s -H "Metadata-Flavor: Google" \
  http://metadata.google.internal/computeMetadata/v1/instance/attributes/CONTAINER_IMAGE)

PROJECT_ID=$(curl -s -H "Metadata-Flavor: Google" \
  http://metadata.google.internal/computeMetadata/v1/instance/attributes/PROJECT_ID)

echo "Container image: \${CONTAINER_IMAGE}"
echo "Project ID: \${PROJECT_ID}"

# Configure docker to use gcloud credential helper (VM service account has permissions)
gcloud auth configure-docker --quiet || true

# Pull & run
docker pull "\${CONTAINER_IMAGE}"
docker rm -f fastapi-app || true
docker run -d --restart unless-stopped --name fastapi-app -p 8000:8000 \
  -e PROJECT_ID="\${PROJECT_ID}" \
  -e CONTAINER_IMAGE="\${CONTAINER_IMAGE}" \
  "\${CONTAINER_IMAGE}"

echo "Container started"
