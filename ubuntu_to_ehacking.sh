#!/usr/bin/env bash
set -e

# Which branch (or tag) of ansible-ehacking to deploy. Defaults to main; override
# for testing a feature branch, e.g.:
#   branch=feat/ubuntu-26.04-podman curl -s https://raw.githubusercontent.com/eHacking-WebSec/ansible-ehacking/refs/heads/main/ubuntu_to_ehacking.sh | bash
BRANCH="${branch:-${BRANCH:-main}}"
echo "### Deploying ansible-ehacking branch: ${BRANCH}"

# Optionally pin the local-docker-setup repo to a branch/tag too (separate repo,
# so it has its own branch name). Unset => the playbook's default (main):
#   setup_branch=feat/podman-offline-modernization branch=... curl -s ... | bash
SETUP_BRANCH="${setup_branch:-${SETUP_BRANCH:-}}"
EXTRA_VARS=()
if [ -n "${SETUP_BRANCH}" ]; then
    echo "### Pinning local-docker-setup to branch: ${SETUP_BRANCH}"
    EXTRA_VARS+=(-e "ehacking_version=${SETUP_BRANCH}")
fi

if ! command -v ansible-playbook &> /dev/null || ! command -v git &> /dev/null; then
    echo "### Updating Packages"
    sudo apt update
    echo "### Installing ansible and git"
    sudo apt install -y ansible git
else
    echo "### Ansible and git already installed, skipping installation..."
fi
if [ ! -d "ansible-ehacking" ]; then
    echo "### Cloning Git Repository (${BRANCH})"
    git clone --depth 1 --branch "${BRANCH}" https://github.com/eHacking-WebSec/ansible-ehacking.git
    cd ansible-ehacking
else
    echo "### Git repository already exists, switching to ${BRANCH} and updating..."
    cd ansible-ehacking
    git fetch --depth 1 origin "${BRANCH}"
    git checkout -B "${BRANCH}" FETCH_HEAD
fi
# The apt `ansible` bundle already ships ansible.posix + community.general; this
# is a safety net for thin ansible-core-only hosts.
echo "### Ensuring required Ansible collections"
ansible-galaxy collection install -r provisioning/requirements.yml
echo "### Deployment via ansible"
sudo ansible-playbook -i provisioning/inventory/hosts.yml provisioning/playbook.yml "${EXTRA_VARS[@]}"
