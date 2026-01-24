#!/bin/sh -eux

# Bootstrap pkg package manager
env ASSUME_ALWAYS_YES=YES pkg bootstrap

# Update pkg repository
pkg update

# Install Python for Ansible
pkg install -y python3

# Create symlinks for python and pip if they don't exist
if [ ! -e /usr/local/bin/python ]; then
    ln -s /usr/local/bin/python3 /usr/local/bin/python
fi

# Verify Python installation
python --version
