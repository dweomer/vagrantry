variable "virtualbox" {
  description = "virtualbox provider defaults"
  type = object({
    builder = string
    export  = object({ format = string })
    disk    = object({ adapter = string, device = string, size = number })
    iso     = object({ adapter = string })
    net     = object({ adapter = string })
  })
  default = {
    builder = "virtualbox-iso"
    export = {
      format = "ovf" // https://www.packer.io/docs/builders/virtualbox/iso#format
    }
    disk = {
      adapter = "ide" // https://www.packer.io/docs/builders/virtualbox/iso#hard_drive_interface
      device  = "sda"
      size    = 16384 // https://www.packer.io/docs/builders/virtualbox/iso#disk_size
    }
    iso = {
      adapter = "sata" // https://www.packer.io/docs/builders/virtualbox/iso#iso_interface
    }
    net = {
      adapter = "82540EM" // https://www.packer.io/docs/builders/virtualbox/iso#nic_type
    }
  }
}

source "virtualbox-iso" "vagrant" {
  hard_drive_interface = local.build.vm.disk.adapter
  iso_interface        = local.build.vm.iso.adapter
  nic_type             = local.build.vm.net.adapter
  vm_name              = local.build.vm.name
  guest_os_type        = local.build.vm.type
  guest_additions_mode = "disable"

  vboxmanage = try(coalescelist(var["vboxmanage"]), [
    ["modifyvm", "{{.Name}}", "--clipboard", "disabled"],
    ["modifyvm", "{{.Name}}", "--draganddrop", "disabled"],
  ])
  vboxmanage_post = try(coalescelist(var["vboxmanage_post"]), [
    ["modifyvm", "{{.Name}}", "--cpus", "1"],
    ["modifyvm", "{{.Name}}", "--memory", "512"],
    ["modifyvm", "{{.Name}}", "--vrde", "off"],
  ])
}
