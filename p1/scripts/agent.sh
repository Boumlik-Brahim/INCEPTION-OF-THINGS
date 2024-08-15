#!/bin/bash

SERVER_IP="192.168.56.110"
TOKEN=$(sudo cat /vagrant/node-token)
curl -sfL https://get.k3s.io | sh -s - agent --server https://$SERVER_IP:6443 --token=$TOKEN --node-ip=192.168.56.111