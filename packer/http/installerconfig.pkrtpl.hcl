DISTRIBUTIONS="base.txz kernel.txz"
PARTITIONS=ada0
nonInteractive="YES"

#!/bin/sh
################################################################################
# FreeBSD Unattended Installation Post-Install Script
# This script runs in a chroot environment after the base system is installed
################################################################################

# Set hostname
echo 'hostname="${vm_hostname}"' >> /etc/rc.conf

# Enable ZFS
echo 'zfs_enable="YES"' >> /etc/rc.conf

# Enable SSH daemon
echo 'sshd_enable="YES"' >> /etc/rc.conf

# Configure network interface for DHCP (IPv4 only)
# Detect the first network interface and configure it
INTERFACE=$(ifconfig -l | awk '{print $1}')
echo "ifconfig_$${INTERFACE}=\"DHCP\"" >> /etc/rc.conf

# Disable IPv6
echo 'ipv6_activate_all_interfaces="NO"' >> /etc/rc.conf

# Set timezone to UTC
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# Configure SSH for root login with password
# This is needed for Packer to connect and provision the system
cat >> /etc/ssh/sshd_config << 'SSHEOF'
PermitRootLogin yes
PasswordAuthentication yes
SSHEOF

# Set root password
echo "${vm_ssh_password}" | pw usermod root -h 0

# Enable core dumps (optional, for debugging)
echo 'dumpdev="AUTO"' >> /etc/rc.conf

# Reboot into the installed system
reboot
