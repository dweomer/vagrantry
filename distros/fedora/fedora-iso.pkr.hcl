variable "iso_arch" {
  default = "x86_64"
}

variable "iso_version" {
  type    = string
  default = null
}

variable "iso_edition" {
  type    = string
  default = null
}

variable "iso_vault_checksum_file" {
  type    = string
  default = null
}

variable "iso_mirrors" {
  default = [
    "file:///srv/fedora", # setup an nfs mount to your nas with mirrored content ...
    "https://dl.fedoraproject.org/pub/fedora/",
    "https://download-ib01.fedoraproject.org/pub/fedora/",
    "https://mirror.arizona.edu/pub/fedora",
    "https://ftp.osuosl.org/pub/fedora",
    "https://ftp.iij.ad.jp/pub/linux/fedora",
  ]
  description = "Visit https://admin.fedoraproject.org/mirrormanager/mirrors/Fedora/34 to see the mirrors closest to you"
}

variable "iso_checksums" {
  default = {
    "34-1.2" : {
      "x86_64" : { # https://dl.fedoraproject.org/pub/fedora/linux/releases/34/Server/x86_64/iso/Fedora-Server-34-1.2-x86_64-CHECKSUM
        "dvd" : "sha256:0b9dc87d060c7c4ef89f63db6d4d1597dd3feaf4d635ca051d87f5e8c89e8675",
        "netinst" : "sha256:e1a38b9faa62f793ad4561b308c31f32876cfaaee94457a7a9108aaddaeec406",
      },
      "aarch64" : { # https://dl.fedoraproject.org/pub/fedora/linux/releases/34/Server/aarch64/iso/Fedora-Server-34-1.2-aarch64-CHECKSUM
        "dvd" : "sha256:57baee600b29d6c751626d3d94b76053e65d378f562869cb89b26a594b47f52a",
        "netinst" : "sha256:925fc062e0be73e86d32ba0e969fbbde549eb80ac6342e82bc01457220b82311",
      },
      "armhfp" : { # https://dl.fedoraproject.org/pub/fedora/linux/releases/34/Server/armhfp/iso/Fedora-Server-34-1.2-armhfp-CHECKSUM
        "dvd" : "sha256:7376107da2fb292a99bb5f384f437c5021b00dbec102390b0642d499e0e515eb",
        "netinst" : "sha256:2a35579bbb7f2b1588e3c615daaeda18aa4d2fb1216f8e556bb2b3b14c809418",
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
    arch    = var.iso_arch
    edition = coalesce(var.iso_edition, "dvd")
    version = coalesce(var.iso_version, "34-1.2")
    target = {
      path      = var.iso_target_path
      extension = var.iso_target_extension
    }
    vault = {
      checksum_file = coalesce(var.iso_vault_checksum_file, format("Fedora-Server-%s-%s-CHECKSUM", coalesce(var.iso_version, "34-1.2"), var.iso_arch))
    }
  }
}
