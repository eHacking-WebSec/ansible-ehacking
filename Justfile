# eHacking Ansible provisioner — shortcuts. `just` lists recipes.
# Turns a clean Ubuntu 26.04 install into the training laptop. Run on the target
# (the playbook is local-connection). Recipes that touch the system use sudo via
# ansible's --become, so they prompt for the sudo password unless NOPASSWD.

set shell := ["bash", "-cu"]

inventory := "provisioning/inventory/hosts.yml"
playbook  := "provisioning/playbook.yml"

default:
    @just --list --unsorted

# Full provision (all roles).
provision:
    ansible-playbook -i {{inventory}} {{playbook}}

# Run a single role by its tag, e.g. `just install firefox`. After the tag
# normalization this works for every role: ubuntu, container-runtime, common,
# firefox, chromium, burpsuite, vscode, bruno, postman, ehacking-deploy.
install ROLE:
    ansible-playbook -i {{inventory}} {{playbook}} --tags {{ROLE}}

# Online refresh: apt update/upgrade + package install + redeploy the stack with
# an image pull.
update:
    ansible-playbook -i {{inventory}} {{playbook}} --tags update,upgrade,packages
    ansible-playbook -i {{inventory}} {{playbook}} --tags ehacking-deploy -e ehacking_pull_images=true

# Dry run: show what would change without touching anything.
check:
    ansible-playbook -i {{inventory}} {{playbook}} --check --diff

# (Re)deploy just the offline stack + CA trust.
deploy:
    ansible-playbook -i {{inventory}} {{playbook}} --tags ehacking-deploy

# (Re)configure just the rootless podman runtime.
runtime:
    ansible-playbook -i {{inventory}} {{playbook}} --tags container-runtime

# Run an arbitrary tag set, e.g. `just tags system,packages`.
tags TAGS:
    ansible-playbook -i {{inventory}} {{playbook}} --tags {{TAGS}}

# Run everything except a tag set, e.g. `just skip postman,bruno`.
skip TAGS:
    ansible-playbook -i {{inventory}} {{playbook}} --skip-tags {{TAGS}}

# Install the required Ansible collections (apt's `ansible` already bundles them).
deps:
    ansible-galaxy collection install -r provisioning/requirements.yml
