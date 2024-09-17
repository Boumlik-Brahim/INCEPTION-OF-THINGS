#!/bin/bash

# install docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# install k3d
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# create k3d cluster
k3d cluster create my-cluster --agents 1

# Create Argo CD Namespace
kubectl create namespace argocd

# Create Dev Namespace
kubectl create namespace dev

# create Gitlab namespace
kubectl create namespace gitlab

# Install Argo CD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# expose agrocd
echo "waiting for argocd pods to start.."
kubectl wait --for=condition=Ready pods --all --timeout=69420s -n argocd
kubectl port-forward svc/argocd-server -n argocd 8080:443 --address="0.0.0.0" 2>&1 > /var/log/argocd-log &

# Install the Argo CD CLI
curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/download/v2.6.7/argocd-linux-amd64
chmod +x argocd
sudo mv argocd /usr/local/bin/

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash


# Login to argocd using CLI
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo)
echo ${ARGOCD_PASSWORD}
argocd login localhost:8080 --username admin --password $ARGOCD_PASSWORD --insecure --grpc-web

# change context namespace
kubectl config set-context --current --namespace=argocd

# create app in agrocd
argocd app create my-app --repo https://github.com/Boumlik-Brahim/ybensell --path dev --dest-server https://kubernetes.default.svc --dest-namespace dev
sleep 10

#view the app
argocd app get my-app

# toggle app autosync
argocd app set my-app --sync-policy automated
sleep 10

# sync the app (deploy)
argocd app sync my-app

# expose the app via port forwarding (unclean, should do ingress instead)
while true; do
      echo "waiting for dev pods to start..."
      kubectl wait --for=condition=Ready pods --all --timeout=6969s -n dev  2>&1 > /var/log/dev-wait.log && echo "done, use curl localhost:8888 to check.."
      kubectl port-forward services/wil-playground 8888 -n dev --address="0.0.0.0" 2>&1 > /var/log/dev-server.log 
      sleep 10  # Add a small delay to prevent excessive CPU usage
done &


# set cubctl context to gitlab namespace
kubectl config set-context --current --namespace=gitlab

# install gitlab
helm repo add gitlab https://charts.gitlab.io
helm search repo -l gitlab/gitlab

helm upgrade --install gitlab gitlab/gitlab \
  --timeout 600s \
  --set global.hosts.domain=localhost \
  --set global.hosts.externalIP=127.0.0.1 \
  --set certmanager-issuer.email=me@example.com \
  --set postgresql.image.tag=13.6.0 \
  --set livenessProbe.initialDelaySeconds=220 \
  --set readinessProbe.initialDelaySeconds=220

# expose gitlab via port 82
kubectl port-forward services/gitlab-nginx-ingress-controller 8082:443 -n gitlab --address="0.0.0.0" 2>&1 > /var/log/gitlab-webserver.log &
kubectl get secret gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo
