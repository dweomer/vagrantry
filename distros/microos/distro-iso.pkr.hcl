variable "iso_arch" {
  default = env("VAGRANTRY_ISO_ARCH")
}

variable "iso_version" {
  default = env("VAGRANTRY_ISO_VERSION")
}

variable "iso_edition" {
  default = env("VAGRANTRY_ISO_EDITION")
}

variable "iso_mirrors" {
  default = [
    "_mirror/opensuse",
    "/srv/mirror/opensuse", # setup an nfs mount to your nas with mirrored content ...
    "https://download.opensuse.org",
  ]
  description = "https://download.opensuse.org"
}

variable "iso_checksums" {
  default = {
    "Current" : {
      "x86_64" : {
        "DVD" : "none",
      },
    },
  }
}

variable "iso_target_path" {
  type    = string
  default = null
}

variable "iso_target_extension" {
  type    = string
  default = "iso"
}

local "iso" {
  expression = {
    arch    = coalesce(var.iso_arch, "x86_64")
    edition = coalesce(var.iso_edition, "DVD")
    version = coalesce(var.iso_version, "Current")
    target = {
      path      = var.iso_target_path
      extension = var.iso_target_extension
    }
  }
}
