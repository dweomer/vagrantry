source "vmware-iso" "vagrant" {
  boot_command = [
    "<esc><wait>",
    "linux ${local.kickstart.param}=${local.kickstart.url} ${var.boot_append}",
    "<enter><wait>",
  ]
  boot_wait            = var.boot_wait
  cpus                 = local.vm.cpus
  memory               = local.vm.memory
  disk_size            = local.vm.disk_size
  disk_adapter_type    = local.vm.disk_type
  cdrom_adapter_type   = "ide"
  format               = local.output.format
  guest_os_type        = "fedora64Guest"
  headless             = var.headless
  http_directory       = local.kickstart.dir
  iso_checksum         = lookup(lookup(lookup(var.iso_checksums, local.iso.version, {}), local.iso.arch, {}), local.iso.edition, "file:https://dl.fedoraproject.org/pub/fedora/linux/releases/${local.semver_major}/Server/${local.iso.arch}/iso/${local.iso.vault.checksum_file}")
  iso_target_path      = local.iso.target.path
  iso_target_extension = local.iso.target.extension
  iso_urls             = formatlist("%s/%s", distinct(var.iso_mirrors), local.iso_path)
  network_adapter_type = local.vm.nic_type
  output_directory     = "${local.output.root}.vmware"
  shutdown_command     = var.shutdown_command
  shutdown_timeout     = var.shutdown_timeout
  ssh_username         = var.ssh_username
  ssh_password         = var.ssh_password
  ssh_wait_timeout     = var.ssh_wait_timeout
  vm_name              = local.vm.name
}

local "vmware" {
  expression = {
    build = var.provider == "vmware" ? ["build"] : []
  }
}

build {
  // to enable this build: `packer build --parallel-builds=1 --var provider=vmware <vars-and-flags> .`
  dynamic "source" {
    labels   = ["vmware-iso.vagrant"]
    for_each = local.vmware.build
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
      files = ["${local.output.root}.vmware/**"]
    }
    post-processor "compress" {
      output = "${local.output.root}.vmware.tar"
    }
  }
}
