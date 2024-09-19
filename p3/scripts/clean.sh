#!/bin/sh
# Stop and remove K3d cluster
k3d cluster delete mycluster

# Remove Docker
sudo apt-get purge -y docker-ce docker-ce-cli containerd.io
sudo rm -rf /var/lib/docker /etc/docker
sudo groupdel docker
sudo rm -rf /var/run/docker.sock

# Remove K3d
sudo rm -f /usr/local/bin/k3d

# Remove kubectl
sudo rm -f /usr/local/bin/kubectl

# Remove Argo CD CLI
sudo rm -f /usr/local/bin/argocd

# Remove namespaces (this step is not necessary if the K3d cluster is deleted, but included for completeness)
kubectl delete namespace argocd
kubectl delete namespace dev

# Clean up Docker related packages
sudo apt-get autoremove -y
sudo apt-get autoclean

echo "Cleanup complete. The following components have been removed:"
echo "- K3d cluster"
echo "- Docker"
echo "- K3d binary"
echo "- kubectl binary"
echo "- Argo CD CLI"
echo "- argocd and dev namespaces"

echo "You may need to reboot your system for all changes to take effect."