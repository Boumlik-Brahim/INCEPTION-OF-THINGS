#!/bin/bash

# Set variables
ARGOCD_SERVER="localhost:8080"
GITHUB_REPO="http://gitlab-service.gitlab.svc.cluster.local/root/aa.git" # Change this to your Gitlab repository
APP_NAME="wil-playground"
APP_NAMESPACE="dev"
REPO_PATH="."  # The path in your repo where K8s manifests are stored

# Get the initial admin password
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

# Optional: Sync the application immediately
argocd app sync $APP_NAME

echo "Argo CD application '$APP_NAME' has been created and synced."