variable "defaults" {
  description = "per provider map of defaults"
  default = {
    libvirt = {
      disk_name     = "vda"
      disk_type     = "virtio"
      nic_type      = "virtio-net"
      output_format = "qcow2"
    },
    virtualbox = {
      disk_name     = "sda"
      disk_type     = "ide"
      nic_type      = "82540EM"
      output_format = "ovf"
    },
    vmware = {
      disk_name     = "sda"
      disk_type     = "sata"
      nic_type      = "e1000"
      output_format = "vmx"
    },
  }
}

variable "headless" {
  type    = bool
  default = true
}

variable "provider" {
  type        = string
  default     = "unknown"
  description = "`libvirt` or `virtualbox`"
}

variable "build_version" {
  type    = string
  default = "16.0.0"
}

variable "build_metadata" {
  type        = string
  default     = ""
  description = "semver build metadata, see https://semver.org/"
}

variable "build_timestamp" {
  type        = string
  default     = null
  description = "semver build metadata, see https://semver.org/"
}

local "build" {
  expression = {
    version  = coalesce(var.build_version, "16.0.0")
    metadata = var.build_metadata
    timestamp = coalesce(
      var.build_timestamp,
      try(trimspace(file("${abspath(var.output_directory)}/.timestamp")), null),
      formatdate("YYYYMMDDhhmmss", timestamp()),
    )
  }
}

variable "output_directory" {
  type    = string
  default = "_output"
}

variable "output_format" {
  type    = string
  default = null
}

variable "output_name" {
  type    = string
  default = null
}

local "output" {
  expression = {
    format = try(coalesce(var.output_format, var.defaults[var.provider]["output_format"]), null)
    root   = join("/", [var.output_directory, local.build.timestamp, "microos", local.semver_major, local.arch, local.vm.name])
  }
}

variable "autoyast_dir" {
  type    = string
  default = null
}

variable "autoyast_url" {
  type    = string
  default = null
}

variable "autoyast_param" {
  type    = string
  default = null
}

local "autoyast" {
  expression = {
    dir   = coalesce(var.autoyast_dir, "${path.root}/autoyast")
    url   = coalesce(var.autoyast_url, "http://{{ .HTTPIP }}:{{ .HTTPPort }}/${var.provider}.xml")
    param = coalesce(var.autoyast_param, "lang=en_US textmode=1 autoyast")
  }
}

variable "boot_wait" {
  type    = string
  default = "10s"
}

variable "boot_append" {
  type    = string
  default = "biosdevname=0 net.ifnames=0 netdevice=eth0 netsetup=dhcp"
}

variable "cpus" {
  type    = number
  default = 2
}

variable "disk_size" {
  type    = number
  default = 16384
}

variable "disk_type" {
  type    = string
  default = null
}

variable "disk_name" {
  type    = string
  default = null
}

variable "memory" {
  type        = number
  default     = 2048
  description = "megabytes"
}

variable "nic_type" {
  type    = string
  default = null
}

local "vm" {
  expression = {
    name      = coalesce(var.output_name, format("microos-v%s.%s-%s", local.build.version, local.iso.arch, lower(local.iso.edition)))
    cpus      = var.cpus
    memory    = var.memory
    disk_name = try(coalesce(var.disk_name, var.defaults[var.provider]["disk_name"]), null)
    disk_type = try(coalesce(var.disk_type, var.defaults[var.provider]["disk_type"]), null)
    disk_size = var.disk_size
    nic_type  = try(coalesce(var.nic_type, var.defaults[var.provider]["nic_type"]), null)
  }
}

variable "shutdown_command" {
  type    = string
  default = "sudo /sbin/shutdown --no-wall -P now"
}

variable "shutdown_timeout" {
  type    = string
  default = "1m"
}

variable "ssh_username" {
  type    = string
  default = "vagrant"
}

variable "ssh_password" {
  type    = string
  default = "vagrant"
}

variable "ssh_wait_timeout" {
  type    = string
  default = "10m"
}

locals {
  arch         = lookup({ "x86_64" : "amd64", "aarch64" : "arm64" }, local.iso.arch, local.iso.arch)
  semver       = regex("^v?(?P<major>0|[1-9]\\d*)(?:\\.(?P<minor>0|[1-9]\\d*))?(?:\\.(?P<patch>0|[1-9]\\d*))?(?:-(?P<pre>(?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\\.(?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\\+(?P<meta>[0-9a-zA-Z-]+(?:\\.[0-9a-zA-Z-]+)*))?$", local.build.version)
  semver_major = try(coalesce(local.semver["major"]), "0")
  semver_minor = try(coalesce(local.semver["minor"]), "0")
  semver_patch = try(coalesce(local.semver["patch"]), "0")
  semver_core  = "${local.semver_major}.${local.semver_minor}.${local.semver_patch}"
  semver_meta  = try(coalesce(local.semver["meta"]), local.build.metadata)
  semver_pre   = try(coalesce(local.semver["pre"]), "")
  semver_str = format("%s%s%s", local.semver_core,
    local.semver_pre == "" ? "" : format("-%s", local.semver_pre),
    local.semver_meta == "" ? "" : format("+%s", local.semver_meta),
  )
  semver_tag = format("v%s", local.semver_str)
  iso_path = format("tumbleweed/iso/openSUSE-MicroOS-%s-%s-%s.iso", local.iso.edition, local.iso.arch,
    local.iso.version == "Current" ? local.iso.version : format("%s-Media", local.iso.version),
  )
  iso_checksum = lookup(lookup(lookup(var.iso_checksums, local.iso.version, {}), local.iso.arch, {}), local.iso.edition, "file:https://download.opensuse.org/${local.iso_path}.sha256")

}

variable "vagrantfile_template" {
  type    = string
  default = null
}

local "vagrantfile" {
  expression = {
    template = coalesce(var.vagrantfile_template, "${path.root}/Vagrantfile")
  }
}

source "null" "microos" {
  communicator = "none"
}

build {
  source "null.microos" {
    name = "build-microos"
  }
  provisioner "shell-local" {
    inline = [
      "echo ARCH:   '${jsonencode(local.arch)}'",
      "echo BUILD:  '${jsonencode(local.build)}'",
      "echo OUTPUT: '${jsonencode(local.output)}'",
      "echo ISO:    '${jsonencode(local.iso)}'",
      "echo VM:     '${jsonencode(local.vm)}'",
    ]
  }
}
