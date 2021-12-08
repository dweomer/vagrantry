variable "iso" {
  type = object({
    arch     = string, distro = string, edition = string, variant = string, version = string,
    checksum = string, mirrors = list(string), url = string,
    target   = object({ path = string, extension = string, })
  })
  default = {
    arch     = null, distro = null, edition = null, variant = null, version = null,
    checksum = "none", mirrors = [], url = null
    target   = { path = null, extension = "iso", }
  }
}

variable "iso_arch" {
  type        = string
  default     = env("VAGRANTRY_ISO_ARCH")
  description = "iso.arch override"
}

variable "iso_distro" {
  type        = string
  default     = env("VAGRANTRY_ISO_DISTRO")
  description = "iso.distro override"
}

variable "iso_edition" {
  type        = string
  default     = env("VAGRANTRY_ISO_EDITION")
  description = "iso.edition override"
}

variable "iso_variant" {
  type        = string
  default     = env("VAGRANTRY_ISO_VARIANT")
  description = "iso.variant override"
}

variable "iso_version" {
  type        = string
  default     = env("VAGRANTRY_ISO_VERSION")
  description = "iso.version override"
}

variable "iso_checksum" {
  type        = string
  default     = env("VAGRANTRY_ISO_CHECKSUM")
  description = "iso.checksum override"
}

variable "iso_mirrors" {
  type        = list(string)
  default     = [env("VAGRANTRY_ISO_MIRROR")]
  description = "iso.mirrors override"
}

variable "iso_url" {
  type        = string
  default     = env("VAGRANTRY_ISO_URL")
  description = "iso.url override"
}

variable "iso_target_path" {
  type        = string
  default     = env("VAGRANTRY_ISO_TARGET_PATH")
  description = "iso.target.path override"
}

variable "iso_target_extension" {
  type        = string
  default     = env("VAGRANTRY_ISO_TARGET_EXTENSION")
  description = "iso.target.extension override"
}

local "iso" {
  expression = {
    arch = try(
      coalesce(var.iso_arch), coalesce(var.iso.arch), null,
    )
    distro = try(
      coalesce(var.iso_distro), coalesce(var.iso.distro), null,
    )
    edition = try(
      coalesce(var.iso_edition), coalesce(var.iso.edition), null,
    )
    variant = try(
      coalesce(var.iso_variant), coalesce(var.iso.variant), null,
    )
    version = try(
      coalesce(var.iso_version), coalesce(var.iso.version), null,
    )
    checksum = try(
      coalesce(var.iso_checksum), coalesce(var.iso.checksum), null,
    )
    mirrors = distinct(try(
      compact(var.iso_mirrors), compact(var.iso.mirrors), null,
    ))
    url = try(
      coalesce(var.iso_url), coalesce(var.iso.url), null,
    )
    target = {
      path = try(
        coalesce(var.iso_target_path), coalesce(var.iso.target.path), null,
      )
      extension = try(
        coalesce(var.iso_target_extension), coalesce(var.iso.target.extension), null,
      )
    }
  }
}

source "null" "iso" {
  communicator = "none"
}
