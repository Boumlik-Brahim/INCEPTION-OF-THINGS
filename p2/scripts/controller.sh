#!/bin/bash

SERVER_IP="192.168.56.110"

curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644 --node-ip=$SERVER_IP
