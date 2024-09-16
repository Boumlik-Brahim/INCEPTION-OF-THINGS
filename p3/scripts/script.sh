#!/bin/bash

# install docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# install k3d
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# create k3d cluster
k3d cluster create my-cluster --agents 1

# Create Argo CD Namespace
kubectl create namespace argocd

# Create Dev Namespace
kubectl create namespace dev

# Install Argo CD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Expose the Argo CD API Server
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Install the Argo CD CLI
curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/download/v2.6.7/argocd-linux-amd64
chmod +x argocd
sudo mv argocd /usr/local/bin/

# Login to argocd using CLI
kubectl port-forward svc/argocd-server -n argocd 9393:443 &>/dev/null &
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo)
argocd login localhost:9393 --username admin --password $ARGOCD_PASSWORD --insecure --grpc-web


