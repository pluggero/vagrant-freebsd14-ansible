##################################################################################
# SOURCES
##################################################################################
source "virtualbox-iso" "freebsd14" {
  vm_name              = "${var.vm_name}"
  iso_url              = local.freebsd_iso_url_x86_64
  iso_checksum         = local.freebsd_iso_checksum_x86_64
  iso_target_path      = "${path.root}/inputs/${local.freebsd_iso_name_x86_64}"
  http_content = {
    "/installerconfig" = templatefile("http/installerconfig.pkrtpl.hcl", {
      vm_hostname      = var.vm_hostname
      vm_ssh_password  = var.vm_ssh_password
    })
  }
  shutdown_command     = local.vm_nonroot_shutdown_command
  ssh_username         = var.vm_ssh_username
  ssh_password         = var.vm_ssh_password
  ssh_timeout          = var.vm_ssh_timeout
  boot_command         = local.freebsd_boot_command_x86_64
  boot_wait            = var.vm_boot_wait
  disk_size            = var.vm_disk_size
  guest_os_type        = "FreeBSD_64"
  cpus                 = var.vm_cpu_core
  memory               = var.vm_mem_size
  headless             = var.vbox_vm_headless
  hard_drive_interface = "sata"
  iso_interface        = "sata"
  format               = var.vbox_output_format
  output_directory     = "${path.root}/outputs/${local.vbox_output_name}"
  guest_additions_mode = var.vbox_guest_additions
  vboxmanage           = [["modifyvm", "{{.Name}}", "--nat-localhostreachable1", "on"]]
  vboxmanage_post      = [
    ["modifyvm", "{{.Name}}", "--memory", var.vbox_post_mem_size],
    ["modifyvm", "{{.Name}}", "--cpus", var.vbox_post_cpu_core],
    ["modifyvm", "{{.Name}}", "--clipboard-mode", var.vbox_post_clipboard_mode],
  ]
}



##################################################################################
# BUILD
##################################################################################

build {
  sources = [
    "source.virtualbox-iso.freebsd14"
  ]

  provisioner "shell" {
    execute_command = "{{.Vars}} sh '{{.Path}}'"
    script = "${path.root}/scripts/bootstrap.sh"
  }

  provisioner "ansible" {
    galaxy_file          = "${path.root}/../ansible/requirements.yml"
    galaxy_force_install = true
    collections_path     = "${path.root}/../ansible/collections"
    roles_path           = "${path.root}/../ansible/roles"
    playbook_file        = "${path.root}/../ansible/playbooks/main.yml"
    user                 = "${var.vm_ssh_username}"
    ansible_env_vars = [ 
      # To enable piplining, you have to edit sudoers file
      # See:https://docs.ansible.com/ansible/latest/reference_appendices/config.html#ansible-pipelining
      # "ANSIBLE_PIPELINING=true",
      "ANSIBLE_ROLES_PATH=${path.root}/../ansible/roles",
      "ANSIBLE_FORCE_COLOR=true",
      "ANSIBLE_HOST_KEY_CHECKING=false",
    ]
    extra_arguments = [
      "--extra-vars",
      "ansible_become_password=${var.vm_ssh_password}",
    ]
  }

  provisioner "shell" {
    execute_command = "{{.Vars}} sh '{{.Path}}'"
    script = "${path.root}/scripts/cleanup.sh"
  }

  post-processors {
    post-processor "artifice" {
      files = [
        "${path.root}/outputs/${local.vbox_output_name}/${var.vm_name}-disk001.vmdk",
        "${path.root}/outputs/${local.vbox_output_name}/${var.vm_name}.ovf"
      ]
    }
    post-processor "vagrant" {
      keep_input_artifact = true
      provider_override   = "virtualbox"
      output = "${path.root}/outputs/${local.vbox_output_name}/${var.vm_name}-virtualbox.box"
    }
  }

}
