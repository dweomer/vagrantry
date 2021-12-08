packer {
  required_plugins {
    qemu = { version = "1.0.1", source = "github.com/hashicorp/qemu" }
  }
}

variable "libvirt" {
  description = "libvirt provider defaults"
  type = object({
    builder = string
    export  = object({ format = string })
    disk    = object({ adapter = string, device = string, size = number })
    iso     = object({ adapter = string })
    net     = object({ adapter = string })
  })
  default = {
    builder = "qemu"
    export = {
      format = "qcow2" // https://www.packer.io/docs/builders/qemu#format
    }
    disk = {
      adapter = "virtio" // https://www.packer.io/docs/builders/qemu#disk_interface
      device  = "vda"
      size    = 16384 // https://www.packer.io/docs/builders/qemu#disk_size
    }
    iso = {
      // let the builder figure this out
      adapter = null // https://www.packer.io/docs/builders/qemu#cdrom_interface
    }
    net = {
      adapter = "virtio-net" // https://www.packer.io/docs/builders/qemu#net_device
    }
  }
}

source "qemu" "vagrant" {
  disk_interface  = local.build.vm.disk.adapter
  cdrom_interface = local.build.vm.iso.adapter
  net_device      = local.build.vm.net.adapter
  vm_name         = join(".", compact([local.build.vm.name, local.guest.export.format]))
}
