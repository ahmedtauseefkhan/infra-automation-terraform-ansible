#!/bin/bash

echo "Updating package list..."
sudo apt update

echo "Installing software-properties-common..."
sudo apt install -y software-properties-common

echo "Adding Ansible PPA..."
sudo add-apt-repository --yes --update ppa:ansible/ansible

echo "Installing Ansible..."
sudo apt install -y ansible

echo "Verifying Ansible installation..."
ansible --version

echo "Ansible installation completed."
