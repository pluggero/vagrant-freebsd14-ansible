#!/bin/sh -eux

# Remove old kernel and boot files to save space
rm -rf /boot/kernel.old
# /boot/efi is an MS-DOS mount, allow rm -f to fail
rm -f /boot/efi/EFI/FreeBSD/*-old.efi || true
rm -f /boot/efi/EFI/BOOT/*-old.efi || true

# Remove unique identifiers so each VM gets fresh ones
# Critical for ZFS, NFS v4, and avoiding UUID conflicts
rm -f /etc/hostid
rm -f /etc/machine-id

# Remove SSH host keys (regenerated on first boot)
rm -f /etc/ssh/ssh_host_*

# Remove installation ISOs and temporary build files
rm -f /root/*.iso
rm -f /root/.vbox_version

# Delete unneeded files
rm -f /home/vagrant/*.sh

# Clean temporary files
rm -rf /tmp/*

# Clean freebsd-update cache
rm -rf /var/db/freebsd-update/files/*
rm -f /var/db/freebsd-update/*-rollback
rm -rf /var/db/freebsd-update/install.*

# Clean package manager cache
rm -f /var/db/pkg/repo-*.sqlite
rm -rf /var/db/pkg/repos/FreeBSD
pkg clean -ay || true

# Remove logs
rm -rf /var/log/*

# Add `sync` so Packer doesn't quit too early, before the large file is deleted.
sync
