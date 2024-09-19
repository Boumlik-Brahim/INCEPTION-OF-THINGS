#!/bin/bash

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
# sudo usermod -aG docker $USER

# Install K3d
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Create K3d cluster
k3d cluster create mycluster -p "8888:30000@server:0" -p "30080:30080@server:0"

# Install Argo CD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for Argo CD to be ready
kubectl wait --for=condition=available --timeout=600s deployment/argocd-server -n argocd    

# Create dev namespace
kubectl create namespace dev

# Install Argo CD CLI
sudo curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo chmod +x /usr/local/bin/argocd

# Get Argo CD admin password
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "Argo CD admin password: $ARGOCD_PASSWORD"

# Port forward Argo CD server (run this in the background)
kubectl port-forward svc/argocd-server -n argocd 8080:443 &

echo "Setup complete. You can access Argo CD at https://localhost:8080"
echo "Username: admin"
echo "Password: $ARGOCD_PASSWORD"
echo "Argo CD setup complete."

kubectl create namespace gitlab
kubectl apply -f configs/gitlab-deploy.yaml


