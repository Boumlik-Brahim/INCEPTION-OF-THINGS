#!/bin/bash

apt-get update
apt-get install -y curl

curl -sfL https://get.k3s.io | sh -
echo "Sleeping for 5 seconds to wait for k3s to start"
sleep 5
cp /var/lib/rancher/k3s/server/node-token /vagrant_shared