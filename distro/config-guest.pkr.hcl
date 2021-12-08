variable "guest" {
  type = object({
    type     = string
    cpu      = number
    mem      = number
    disk     = object({ adapter = string, device = string, size = number })
    iso      = object({ adapter = string })
    net      = object({ adapter = string })
    ssh      = object({ username = string, password = string, timeout = string })
    boot     = object({ command = list(string), wait = string })
    shutdown = object({ command = string, timeout = string })
    http     = object({ directory = string, content = map(string) })
    export   = object({ format = string, name = string, root = string })
  })
  default = {
    cpu      = 2,
    mem      = 2048,
    disk     = { adapter = null, device = null, size = 16384 }
    iso      = { adapter = null }
    net      = { adapter = null }
    ssh      = { username = "vagrant", password = "vagrant", timeout = "15m" }
    boot     = { command = [], wait = "10s" }
    shutdown = { command = "sudo /sbin/shutdown --no-wall -P now", timeout = "1m" }
    export   = { format = null, name = null, root = "_output" }
    http     = null
    type     = null
  }
}

variable "guest_cpu" {
  type        = string
  default     = env("VAGRANTRY_GUEST_CPU")
  description = "guest.cpu override"
}

variable "guest_mem" {
  type        = string
  default     = env("VAGRANTRY_GUEST_MEM")
  description = "guest.mem override"
}

variable "guest_disk_adapter" {
  type        = string
  default     = env("VAGRANTRY_GUEST_DISK_ADAPTER")
  description = "guest.disk.adapter override"
}

variable "guest_disk_device" {
  type        = string
  default     = env("VAGRANTRY_GUEST_DISK_DEVICE")
  description = "guest.disk.device override"
}

variable "guest_disk_size" {
  type        = string
  default     = env("VAGRANTRY_GUEST_DISK_SIZE")
  description = "guest.disk.size override"
}

variable "guest_iso_adapter" {
  type        = string
  default     = env("VAGRANTRY_GUEST_ISO_ADAPTER")
  description = "guest.iso.adapter override"
}

variable "guest_net_adapter" {
  type        = string
  default     = env("VAGRANTRY_GUEST_NET_ADAPTER")
  description = "guest.net.adapter override"
}

variable "guest_boot_command" {
  type        = list(string)
  default     = [env("VAGRANTRY_GUEST_BOOT_COMMAND")]
  description = "guest.boot.command override"
}

variable "guest_boot_wait" {
  type        = string
  default     = env("VAGRANTRY_GUEST_BOOT_WAIT")
  description = "guest.boot.wait override"
}

variable "guest_http_directory" {
  type        = string
  default     = env("VAGRANTRY_GUEST_HTTP_DIRECTORY")
  description = "guest.http.directory override"
}

variable "guest_http_content" {
  type        = string
  default     = env("VAGRANTRY_GUEST_HTTP_CONTENT")
  description = "guest.http.content override"
}

variable "guest_shutdown_command" {
  type        = string
  default     = env("VAGRANTRY_GUEST_SHUTDOWN_COMMAND")
  description = "guest.shutdown.command override"
}

variable "guest_shutdown_timeout" {
  type        = string
  default     = env("VAGRANTRY_GUEST_SHUTDOWN_TIMEOUT")
  description = "guest.shutdown.timeout override"
}

variable "guest_ssh_username" {
  type        = string
  default     = env("VAGRANTRY_GUEST_SSH_USERNAME")
  description = "guest.ssh.username override"
}

variable "guest_ssh_password" {
  type        = string
  default     = env("VAGRANTRY_GUEST_SSH_PASSWORD")
  description = "guest.ssh.password override"
}

variable "guest_ssh_timeout" {
  type        = string
  default     = env("VAGRANTRY_GUEST_SSH_TIMEOUT")
  description = "guest.ssh.timeout override"
}

variable "guest_export_format" {
  type        = string
  default     = env("VAGRANTRY_GUEST_EXPORT_FORMAT")
  description = "guest.export.format override"
}

variable "guest_export_name" {
  type        = string
  default     = env("VAGRANTRY_GUEST_EXPORT_NAME")
  description = "guest.export.name override"
}

variable "guest_export_root" {
  type        = string
  default     = env("VAGRANTRY_GUEST_EXPORT_ROOT")
  description = "guest.export.root override"
}

variable "guest_type" {
  type        = string
  default     = env("VAGRANTRY_GUEST_TYPE")
  description = "guest.type override"
}

variable "guest_types" {
  type = map(string)
  default = {
    env("VAGRANTRY_PROVIDER") = env("VAGRANTRY_GUEST_TYPE")
  }
  description = "per provider guest.type override"
}

variable "provider" {
  type        = string
  default     = env("VAGRANTRY_PROVIDER")
  description = "provider name"
}

local "provider" {
  expression = merge(try(var[var.provider], null), {
    name    = try(coalesce(var.provider), null)
    builder = try(coalesce(var[var.provider].builder), coalesce(var.provider), null)
  })
}

local "guest" {
  expression = {
    type = try(
      coalesce(var.guest_type), coalesce(var.guest_types[var.provider]), coalesce(var.guest_types[""]), coalesce(var.guest.type), null,
    )
    cpu = try(
      convert(var.guest_cpu, number), coalesce(var.guest.cpu), null,
    )
    mem = try(
      convert(var.guest_mem, number), coalesce(var.guest.mem), null,
    )
    ssh = {
      username = try(
        coalesce(var.guest_ssh_username), coalesce(var.guest.ssh.username), null,
      )
      password = try(
        coalesce(var.guest_ssh_password), coalesce(var.guest.ssh.password), null,
      )
      timeout = try(
        coalesce(var.guest_ssh_timeout), coalesce(var.guest.ssh.timeout), null,
      )
    }
    disk = {
      adapter = try(
        coalesce(var.guest_disk_adapter), coalesce(var.guest.disk.adapter), coalesce(local.provider.disk.adapter), null,
      )
      device = try(
        coalesce(var.guest_disk_device), coalesce(var.guest.disk.device), coalesce(local.provider.disk.device), null,
      )
      size = try(
        coalesce(var.guest_disk_size), coalesce(var.guest.disk.size), coalesce(local.provider.disk.size), null,
      )
    }
    iso = {
      adapter = try(
        coalesce(var.guest_iso_adapter), coalesce(var.guest.iso.adapter), coalesce(local.provider.iso.adapter), null,
      )
    }
    net = {
      adapter = try(
        coalesce(var.guest_net_adapter), coalesce(var.guest.net.adapter), coalesce(local.provider.net.adapter), null,
      )
    }
    boot = {
      command = try(
        coalescelist(compact(var.guest_boot_command)), coalescelist(var.guest.boot.command), null,
      )
      wait = try(
        coalesce(var.guest_boot_wait), coalesce(var.guest.boot.wait), null,
      )
    }
    http = {
      directory = try(
        coalesce(var.guest_http_directory), coalesce(var.guest.http.directory), null,
      )
      content = try(
        convert(var.guest_http_content, map), var.guest.http.content, null,
      )
    }
    shutdown = {
      command = try(
        coalesce(var.guest_shutdown_command), coalesce(var.guest.shutdown.command), null,
      )
      timeout = try(
        coalesce(var.guest_shutdown_timeout), coalesce(var.guest.shutdown.timeout), null,
      )
    }
    export = {
      name = try(
        coalesce(var.guest_export_name), coalesce(var.guest.export.name), null,
      )
      root = try(
        coalesce(var.guest_export_root), coalesce(var.guest.export.root), null,
      )
      format = try(
        coalesce(var.guest_export_format), coalesce(var.guest.export.format), coalesce(local.provider.export.format), null,
      )
    }
  }
}

source "null" "guest" {
  communicator = "none"
}
