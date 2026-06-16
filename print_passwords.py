#!/usr/bin/env python3
"""Print SHA-512 crypt hashes for the training passwords.

Handy when regenerating vm_user_password in provisioning/group_vars/all.yml.
($6$ SHA-512 hashes are accepted by Ubuntu 26.04; yescrypt $y$ hashes —
produced by `openssl passwd` with no flag — are the modern default but harder
to generate portably, so we emit $6$ here.)
"""
from passlib.hash import sha512_crypt

for pw in ["toor", "kali", "student"]:
    hashed = sha512_crypt.using(rounds=5000).hash(pw)
    print(f"Password hash for '{pw}': {hashed}")
