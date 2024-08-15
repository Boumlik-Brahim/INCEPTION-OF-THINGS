#!/bin/bash

SERVER_IP="192.168.56.110"

curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644 --node-ip=$SERVER_IP

NODE_TOKEN="/var/lib/rancher/k3s/server/node-token"
      while [ ! -e ${NODE_TOKEN} ]
      do
          sleep 2
      done
      sudo cat ${NODE_TOKEN}
      sudo cp ${NODE_TOKEN} /vagrant/