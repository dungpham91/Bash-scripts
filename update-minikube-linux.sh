#!/bin/bash
#
# Author: Dung Pham
# Site: https://devopslite.com
# Date: 24/08/2023
# Purpose: this script use to update minikube to latest version on Linux machine, ex: Ubuntu, Linux Mint...

# Showing current version
echo 'Current version'
echo '---------------'
minikube version
echo ''

# Remove old minikube
minikube delete 
sudo rm -rf /usr/local/bin/minikube

# Download the latest version and setup it
sudo curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo chmod +x minikube
sudo cp minikube /usr/local/bin/
sudo rm minikube
minikube start

# Enabling addons: ingress, dashboard
minikube addons enable ingress
minikube addons enable metrics-server
minikube addons enable dashboard

# Showing enabled addons
echo ''
echo 'Enabled Addons'
echo '--------------'
minikube addons list | grep STATUS && minikube addons list | grep enabled
echo ''

# Showing current status of Minikube
echo 'Current status of Minikube'
echo '--------------------------'
minikube status

# Showing latest version
echo 'Updated version'
echo '---------------'
minikube version
