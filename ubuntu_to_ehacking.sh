#!/usr/bin/env bash
set -e

if ! command -v ansible-playbook &> /dev/null || ! command -v git &> /dev/null; then
    echo "### Updating Packages"
    sudo apt update
    echo "### Installing ansible and git"
    sudo apt install -y ansible git
else
    echo "### Ansible and git already installed, skipping installation..."
fi
if [ ! -d "ansible-ehacking" ]; then
    echo "### Cloning Git Repository"
    git clone --depth 1 https://github.com/eHacking-WebSec/ansible-ehacking.git
    cd ansible-ehacking
else
    echo "### Git repository already exists, updating..."
    cd ansible-ehacking
    git pull
fi
# The apt `ansible` bundle already ships ansible.posix + community.general; this
# is a safety net for thin ansible-core-only hosts.
echo "### Ensuring required Ansible collections"
ansible-galaxy collection install -r provisioning/requirements.yml
echo "### Deployment via ansible"
sudo ansible-playbook -i provisioning/inventory/hosts.yml provisioning/playbook.yml # --skip-tags="postman"
