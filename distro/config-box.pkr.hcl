variable "box" {
  type = object({
    arch     = string
    guest    = string
    variant  = string
    version  = string
    checksum = string
    release  = bool
    url      = string
  })
  default = null
}

variable "box_arch" {
  type        = string
  default     = env("VAGRANTRY_BOX_ARCH")
  description = "box.arch override"
}

variable "box_guest" {
  type        = string
  default     = env("VAGRANTRY_BOX_GUEST")
  description = "box.guest override"
}

variable "box_variant" {
  type        = string
  default     = env("VAGRANTRY_BOX_VARIANT")
  description = "box.variant override"
}

variable "box_version" {
  type        = string
  default     = env("VAGRANTRY_BOX_VERSION")
  description = "box.version override"
}

variable "box_checksum" {
  type        = string
  default     = env("VAGRANTRY_BOX_CHECKSUM")
  description = "box.checksum override"
}

variable "box_release" {
  type        = string
  default     = env("VAGRANTRY_BOX_RELEASE")
  description = "box.release override"
}

variable "box_url" {
  type        = string
  default     = env("VAGRANTRY_BOX_URL")
  description = "box.url override"
}

local "box" {
  expression = {
    arch = try(
      coalesce(var.box_arch), coalesce(var.box.arch), null,
    )
    guest = try(
      coalesce(var.box_guest), coalesce(var.box.guest), null,
    )
    variant = try(
      coalesce(var.box_variant), coalesce(var.box.variant), null,
    )
    version = try(
      coalesce(var.box_version), coalesce(var.box.version), null,
    )
    checksum = try(
      coalesce(var.box_checksum), coalesce(var.box.checksum), null,
    )
    release = try(
      convert(var.box_release, bool), var.box.release, null,
    )
    url = try(
      coalesce(var.box_url), coalesce(var.box.url), null,
    )
  }
}

source "null" "box" {
  communicator = "none"
}
