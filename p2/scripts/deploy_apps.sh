#!/bin/bash

kubectl apply -f /vagrant_shared/configs/app1-deployment.yaml
kubectl apply -f /vagrant_shared/configs/app2-deployment.yaml
kubectl apply -f /vagrant_shared/configs/app3-deployment.yaml
kubectl apply -f /vagrant_shared/configs/ingress.yaml