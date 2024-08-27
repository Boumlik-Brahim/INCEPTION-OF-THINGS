#!/bin/bash



curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

k3d --version

echo "Installation complete!"

# creating cluster
k3d cluster create mycluster --agents 2

# init argocd namespace
kubectl create namespace argocd

# Installing argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

sleep 5

kubectl port-forward svc/argocd-server -n argocd 8080:443
kubectl get secret argocd-initial-admin-secret -n argocd -o yaml | grep "password" | base64 -d
kubectl create namespace dev

