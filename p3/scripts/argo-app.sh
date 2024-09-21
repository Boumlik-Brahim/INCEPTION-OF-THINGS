#!/bin/bash

# Variables
ARGOCD_SERVER="localhost:8080"
GITHUB_REPO="https://github.com/Boumlik-Brahim/ybensell"
APP_NAME="wil-playground"
APP_NAMESPACE="dev"
REPO_PATH="dev"  # path in your repo where K3s manifests are stored

# Get admin password to login to Argo CD
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# Login to Argo CD
argocd login $ARGOCD_SERVER --username admin --password $ARGOCD_PASSWORD --insecure

# Create the application
argocd app create $APP_NAME \
    --repo $GITHUB_REPO \
    --path $REPO_PATH \
    --dest-server https://kubernetes.default.svc \
    --dest-namespace $APP_NAMESPACE \
    --sync-policy automated \
    --auto-prune \
    --self-heal

# Sync the application to deploy it
argocd app sync $APP_NAME

echo "Argo CD application '$APP_NAME' has been created and synced."