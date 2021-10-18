source "virtualbox-iso" "vagrant" {
  boot_command = [
    "<esc><wait>",
    "linux ${local.kickstart.param}=${local.kickstart.url} ${var.boot_append} DISK=${local.vm.disk_name}",
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
  guest_os_type        = "RedHat_64"
  headless             = var.headless
  http_directory       = local.kickstart.dir
  iso_checksum         = lookup(lookup(lookup(var.iso_checksums, local.iso.version, {}), local.iso.arch, {}), local.iso.edition, "file:https://dl.fedoraproject.org/pub/fedora/linux/releases/${local.semver_major}/Server/${local.iso.arch}/iso/${local.iso.vault.checksum_file}")
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
    ["modifyvm", "{{.Name}}", "--hpet", "on"],
    ["modifyvm", "{{.Name}}", "--accelerate3d", "off"],
    ["modifyvm", "{{.Name}}", "--accelerate2dvideo", "off"],
    ["modifyvm", "{{.Name}}", "--bioslogofadein", "off"],
    ["modifyvm", "{{.Name}}", "--bioslogofadeout", "off"],
    ["modifyvm", "{{.Name}}", "--bioslogodisplaytime", "0"],
    ["modifyvm", "{{.Name}}", "--biosbootmenu", "disabled"],
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
