##################################################################################
# LOCALS
##################################################################################

# HTTP Settings

locals {
  freebsd_iso_name_x86_64 = "FreeBSD-${var.vm_guest_os_version}-RELEASE-amd64-disc1.iso"
  freebsd_iso_url_x86_64 = "http://ftp-archive.freebsd.org/pub/FreeBSD-Archive/old-releases/ISO-IMAGES/${var.vm_guest_os_version}/${local.freebsd_iso_name_x86_64}"
  freebsd_iso_checksum_x86_64 = "sha256:${var.vm_guest_iso_checksum_x86_64}"
}

local "http_directory" {
  expression = "${path.root}/http"
}

# Virtual Machine Settings

locals {
  vm_nonroot_shutdown_command = "echo '${var.vm_ssh_password}'|sudo -S shutdown -p now"
} 

local "freebsd_boot_command_x86_64" {
  expression = [
    "<wait1m>",                                                       # Wait for the system to finish booting
    "S<wait5>",                                                       # Open a root shell from the installer menu
    "mkdir /tmp/etc<enter><wait2>",                                   # Create a temporary directory to overlay /etc
    "mount -t unionfs /tmp/etc /etc<enter><wait2>",                   # Overlay /etc with a writable union filesystem
    "rm /etc/resolv.conf<enter><wait2>",                              # Remove existing DNS configuration
    "dhclient -p /tmp/dhclient.pid -l /tmp/dhclient.lease em0<enter><wait20>",  # Obtain network configuration via DHCP on em0
    "fetch -o /tmp/installerconfig http://{{ .HTTPIP }}:{{ .HTTPPort }}/installerconfig<enter><wait10>",  # Download the bsdinstall configuration script
    "bsdinstall script /tmp/installerconfig<enter>"                   # Run automated installation using the downloaded script
  ]
}

# VirtualBox Settings

locals {
    vbox_output_name = "${var.vm_name}-virtualbox-amd64"
    vbox_post_shared_folder_path_full = "${ var.HOME }/${ var.vbox_post_shared_folder_path }"
}

##################################################################################
# VARIABLE DECLARATIONS
##################################################################################

# Environment Variables

variable "HOME" {
  description = "The user's home directory"
  type = string
  default = env("HOME")
}

# Virtual Machine Settings
variable "vm_name" {
  description = "Name of the VM"
  type = string
  default = ""
}

variable "vm_hostname" {
  type        = string
  description = "The hostname of the VM"
}

variable "vm_guest_os_version" {
  description = "Version of guest os to install"
  type = string
  default = ""
}

variable "vm_guest_iso_checksum_x86_64" {
  description = "Checksum of the iso installer"
  type        = string
  default     = ""
}

variable "vm_boot_wait" {
  description = "Time to wait before typing the boot command"
  type = string
  default = ""
}

variable "vm_cpu_core" {
  description = "The number of virtual cpus"
  type = number
}

variable "vm_mem_size" {
  description = "The amount of memory in MB"
  type = number
}

variable "vm_root_shutdown_command" {
  description = "The command to use to gracefully shut down the VM"
  type = string
  default = ""
}

variable "vm_disk_size" {
  description = "The size of the disk to create in MB"
  type = number
}

variable "vm_ssh_timeout" {
  description = "The time to wait for SSH to become available"
  type = string
  default = ""
}

variable "vm_ssh_port" {
  description = "The port to use for SSH"
  type = number
}

variable "vm_ssh_username" {
  description = "The username to use for SSH connection"
  type = string
  default = ""
}

variable "vm_ssh_password" {
  description = "The password to use for SSH connection"
  type = string
  default =  ""
}


# VirtualBox Settings

variable "vbox_vm_headless" {
  description = "Run the VM in headless mode"
  type = bool
  default = true
}

variable "vbox_guest_additions" {
  description = "Install the VirtualBox Guest Additions"
  type = string
  default = ""
}

variable "vbox_post_cpu_core" {
  description = "The number of virtual cpus after the VM has been created"
  type = number
}

variable "vbox_post_mem_size" {
  description = "The amount of memory in MB after the VM has been created"
  type = number
}

variable "vbox_post_bridged_adapter" {
  description = "The bridged network adapter to use after the VM has been created"
  type = string
  default = ""
}

variable "vbox_post_graphics" {
  description = "The graphics controller to use after the VM has been created"
  type = string
  default = ""
}

variable "vbox_post_vram" {
  description = "The amount of video memory to use after the VM has been created"
  type = number
}

variable "vbox_post_accelerate_3d" {
  description = "Enable 3D acceleration after the VM has been created"
  type = string
  default = ""
}

variable "vbox_post_clipboard_mode" {
  description = "The clipboard mode to use after the VM has been created"
  type = string
  default = ""
}

variable "vbox_post_shared_folder_name" {
  description = "The name of the shared folder to create after the VM has been created"
  type = string
  default = ""
}

variable "vbox_post_shared_folder_path" {
  description = "The path of the shared folder to create after the VM has been created"
  type = string
  default = ""
}

variable "vbox_post_shared_folder_mount_point" {
  description = "The mount point of the shared folder to create after the VM has been created"
  type = string
  default = ""
}

variable "vbox_output_format" {
  description = "The format of the output"
  type = string
  default = ""
}
