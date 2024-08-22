sudo apt-get update
sudo apt-get install -y curl

SERVER_IP=192.168.56.110

curl -sfL https://get.k3s.io | K3S_URL=https://$SERVER_IP:6443 K3S_TOKEN=$(cat /var/lib/rancher/k3s/server/node-token) sh -