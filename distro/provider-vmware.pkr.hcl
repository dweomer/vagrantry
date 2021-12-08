variable "vmware" {
  description = "vmware provider defaults"
  type = object({
    builder = string
    export  = object({ format = string })
    disk    = object({ adapter = string, device = string, size = number })
    iso     = object({ adapter = string })
    net     = object({ adapter = string })
  })
  default = {
    builder = "vmware-iso"
    export = {
      format = "vmx" // https://www.packer.io/docs/builders/vmware/iso#format
    }
    disk = {
      adapter = "sata" // https://www.packer.io/docs/builders/vmware/iso#disk_adapter_type
      device  = "sda"
      size    = 16384 // https://www.packer.io/docs/builders/vmware/iso#disk_size
    }
    iso = {
      adapter = "sata" // https://www.packer.io/docs/builders/vmware/iso#cdrom_adapter_type
    }
    net = {
      adapter = "e1000" // https://www.packer.io/docs/builders/vmware/iso#network_adapter_type
    }
  }
}

source "vmware-iso" "vagrant" {
  disk_adapter_type    = local.build.vm.disk.adapter
  cdrom_adapter_type   = local.build.vm.iso.adapter
  network_adapter_type = local.build.vm.net.adapter
  vm_name              = local.build.vm.name
  guest_os_type        = local.build.vm.type
}
