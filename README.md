# eHacking installation via Ansible

This repository turns a clean **Ubuntu 26.04** install into the eHacking
training platform. Previously we shipped a VirtualBox image, but with the spread
of architectures (aarch64 / Apple Silicon) and hypervisors that became
unmaintainable. Instead, Ansible provisions a clean install on any hypervisor:
it installs the tooling (Firefox, Chromium, Burp Suite, VS Code, Bruno/Postman),
sets up rootless Podman, and deploys the offline eHacking stack (the
local-docker-setup), trusting its Step-CA root in the system store and browsers.

The laptops are meant to run **offline**: container images are pre-loaded and the
stack autostarts on login via a systemd `--user` unit.

## Installation

One-liner on a fresh Ubuntu 26.04 box (`curl … | bash` → clones this repo →
`sudo ansible-playbook`):

```sh
curl -s https://raw.githubusercontent.com/eHacking-WebSec/ansible-ehacking/refs/heads/main/ubuntu_to_ehacking.sh | bash
```

…or with wget:

```sh
wget -qO- https://raw.githubusercontent.com/eHacking-WebSec/ansible-ehacking/refs/heads/main/ubuntu_to_ehacking.sh | bash
```

## Justfile

If you have [`just`](https://github.com/casey/just), the repo root ships
shortcuts (`just` lists them):

```sh
just provision        # full provision (all roles)
just install ROLE     # one role by tag, e.g. just install firefox
just check            # dry run (--check --diff)
just update           # online: apt update/upgrade + redeploy with image pull
just deploy           # (re)deploy just the offline stack + CA trust
just runtime          # (re)configure just rootless podman
just deps             # install the required Ansible collections
```

After the tag normalization, `just install <role>` works for **every** role —
including `ubuntu`, `common`, and `burpsuite`, which previously shared catch-all
tags.

## Successfully tested operating systems

- Ubuntu 26.04 LTS (resolute) — amd64 and aarch64

## Future Work

- [ ] Test additional Ubuntu variants (e.g. Kubuntu 26.04)
- [ ] Maybe support Debian?
- [ ] Maybe support Fedora?
