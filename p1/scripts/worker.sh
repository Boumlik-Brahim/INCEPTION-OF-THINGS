#!/bin/bash

apt-get update
apt-get install -y curl

SERVER_IP=192.168.56.110
K3S_TOKEN=$(cat /vagrant_shared/node-token)

curl -sfL https://get.k3s.io | K3S_URL=https://$SERVER_IP:6443 K3S_TOKEN=$K3S_TOKEN  sh -