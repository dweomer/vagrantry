source "virtualbox-iso" "vagrant" {
  boot_command = [
    "<esc><enter><wait>",
    "linux ${var.boot_append}", "<wait>",
    " ${local.autoyast.param}=${local.autoyast.url}", "<wait>",
    "<enter><wait>",
  ]
  boot_wait            = var.boot_wait
  cpus                 = local.vm.cpus
  memory               = local.vm.memory
  disk_size            = local.vm.disk_size
  hard_drive_interface = local.vm.disk_type
  iso_interface        = local.vm.disk_type
  format               = local.output.format
  guest_additions_mode = "disable"
  guest_os_type        = "OpenSUSE_64"
  headless             = var.headless
  http_directory       = local.autoyast.dir
  iso_checksum         = local.iso_checksum
  iso_target_path      = local.iso.target.path
  iso_target_extension = local.iso.target.extension
  iso_urls             = formatlist("%s/%s", distinct(var.iso_mirrors), local.iso_path)
  nic_type             = local.vm.nic_type
  output_directory     = "${local.output.root}.vbox"
  shutdown_command     = var.shutdown_command
  shutdown_timeout     = var.shutdown_timeout
  ssh_username         = var.ssh_username
  ssh_password         = var.ssh_password
  ssh_wait_timeout     = var.ssh_wait_timeout
  vm_name              = local.vm.name

  vboxmanage = [
    ["modifyvm", "{{.Name}}", "--clipboard", "disabled"],
    ["modifyvm", "{{.Name}}", "--draganddrop", "disabled"],
  ]
  vboxmanage_post = [
    ["modifyvm", "{{.Name}}", "--cpus", "1"],
    ["modifyvm", "{{.Name}}", "--memory", "512"],
    ["modifyvm", "{{.Name}}", "--vrde", "off"],
  ]
}

local "virtualbox" {
  expression = {
    build = var.provider == "virtualbox" ? ["build"] : []
  }
}

build {
  // to enable this build: `packer build --parallel-builds=1 --var provider=virtualbox <vars-and-flags> .`
  dynamic "source" {
    labels   = ["virtualbox-iso.vagrant"]
    for_each = local.virtualbox.build
    content {
      name = source.value
    }
  }

  provisioner "shell" {
    inline = [
      "sudo /usr/share/vagrantry/seal.sh",
      "export HISTSIZE=0",
    ]
  }

  post-processors {
    post-processor "vagrant" {
      compression_level    = 9
      keep_input_artifact  = true
      output               = "${local.output.root}.${var.provider}.box"
      vagrantfile_template = local.vagrantfile.template
      provider_override    = var.provider
    }
    post-processor "manifest" {
      output     = "${local.output.root}.packer-manifest.json"
      strip_time = true
      custom_data = {
        arch        = local.arch
        iso_arch    = local.iso.arch
        iso_version = local.iso.version
        iso_edition = local.iso.edition
        vm          = jsonencode(local.vm)
      }
    }
  }
  post-processors {
    post-processor "artifice" {
      files = ["${local.output.root}.vbox/**"]
    }
    post-processor "compress" {
      output = "${local.output.root}.vbox.tar"
    }
  }
}
