variable "detail" {
  type        = string
  default     = env("VAGRANTRY_DETAIL")
  description = "build detail"
}

variable "headless" {
  type        = string
  default     = env("VAGRANTRY_HEADLESS")
  description = "build headless"
}

variable "timestamp" {
  type        = string
  default     = env("VAGRANTRY_TIMESTAMP")
  description = "build timestamp"
}

variable "vagrantfile_template" {
  type    = string
  default = env("VAGRANTRY_VAGRANTFILE_TEMPLATE")
}

local "detail" {
  expression = {
    box   = try(convert(var.detail, bool), contains(split(",", var.detail), "box"), false)
    iso   = try(convert(var.detail, bool), contains(split(",", var.detail), "iso"), false)
    guest = try(convert(var.detail, bool), contains(split(",", var.detail), "guest"), false)
    build = try(convert(var.detail, bool), contains(split(",", var.detail), "build"), false)
  }
}

local "vagrantfile" {
  expression = {
    template = coalesce(var.vagrantfile_template, "${path.root}/Vagrantfile")
  }
}

local "build" {
  expression = {
    detail = {
      box   = try(convert(var.detail, bool), contains(split(",", var.detail), "box"), false)
      iso   = try(convert(var.detail, bool), contains(split(",", var.detail), "iso"), false)
      guest = try(convert(var.detail, bool), contains(split(",", var.detail), "guest"), false)
      build = try(convert(var.detail, bool), contains(split(",", var.detail), "build"), false)
    }
    http = merge(local.guest.http, {
      directory = try(
        replace(
          replace(
            replace(
              replace(
                replace(
                  replace(
                    replace(
                      replace(coalesce(local.guest.http.directory), "{PROVIDER}", lower(local.provider.name)),
                      "{DISTRO/VARIANT}", try(
                        format("%s/%s", lower(local.iso.distro), lower(local.iso.variant)),
                        format("%s", lower(local.iso.distro)),
                    )),
                    "{DISTRO-VARIANT}", try(
                      format("%s-%s", lower(local.iso.distro), lower(local.iso.variant)),
                      format("%s", lower(local.iso.distro)),
                  )),
                "{DISTRO}", lower(local.iso.distro)),
              "{EDITION}", lower(coalesce(local.iso.edition, "UNKNOWN"))),
            "{VARIANT}", lower(coalesce(local.iso.variant, "UNKNOWN"))),
          "{VERSION}", local.iso.version),
        "{ARCH}", lower(local.iso.arch)),
        join("/", compact([
          "distro",
          try(lower(local.iso.distro), null),
          try(lower(local.iso.variant), null),
          "http",
          local.provider.name,
        ])),
        null,
      )
    })
    iso = {
      target = local.iso.target
      checksum = try(
        replace(
          replace(
            replace(
              replace(
                replace(local.iso.checksum, "{ARCH}", local.iso.arch),
              "{DISTRO}", local.iso.distro),
            "{EDITION}", coalesce(local.iso.edition, "UNKNOWN")),
          "{VARIANT}", coalesce(local.iso.variant, "UNKNOWN")),
        "{VERSION}", local.iso.version), null,
      )
      url = try(
        length(local.iso.mirrors) > 0 ? null : replace(
          replace(
            replace(
              replace(
                replace(local.iso.url, "{ARCH}", local.iso.arch),
              "{DISTRO}", local.iso.distro),
            "{EDITION}", coalesce(local.iso.edition, "UNKNOWN")),
          "{VARIANT}", coalesce(local.iso.variant, "UNKNOWN")),
        "{VERSION}", local.iso.version), null,
      )
      urls = try([for mirror in coalescelist(local.iso.mirrors) :
        replace(
          replace(
            replace(
              replace(
                replace(
                  replace(local.iso.url, "{ARCH}", local.iso.arch),
                "{DISTRO}", local.iso.distro),
              "{EDITION}", coalesce(local.iso.edition, "UNKNOWN")),
            "{VARIANT}", coalesce(local.iso.variant, "UNKNOWN")),
          "{VERSION}", local.iso.version),
        "{MIRROR}", mirror)
      ], null)
    }
    timestamp = try(
      coalesce(var.timestamp),
      trimspace(file(format("%s/.timestamp", abspath(local.guest.export.root)))),
      formatdate("YYYYMMDDhhmmss", timestamp()),
    )
    vm = merge({ for k, v in local.guest : k => v if !contains(["export", "http"], k) }, {
      name = try(
        coalesce(local.guest.export.name),
        format("%s-%s.%s",
          lower(join("-", compact([local.iso.distro, local.iso.variant]))),
          local.box.version,
          lower(join("-", compact([local.iso.arch, local.iso.edition]))),
        ),
        null,
      )
    })
  }
}

local "output" {
  expression = {
    root = join("/", [local.guest.export.root, local.build.timestamp, lower(local.iso.distro), local.box.version, lower(local.box.arch), local.build.vm.name])
  }
}

source "null" "build" {
  communicator = "none"
}

build {
  dynamic "source" {
    for_each = [for key in ["box", "iso", "guest", "build"] : key if try(local.detail[key], false)]
    labels   = ["null.${source.value}"]
    content {
      name = "local.${source.value}"
    }
  }
  provisioner "shell-local" {
    inline = [
      for key, val in local[trimprefix(source.name, "local.")] : format("echo '%20s : %s'", jsonencode(key), jsonencode(val))
    ]
  }
}

build {
  dynamic "source" {
    for_each = compact([local.provider.builder])
    labels   = ["${source.value}.vagrant"]
    content {
      name                 = "vagrant.box"
      headless             = try(convert(coalesce(var.headless), bool), true)
      format               = local.guest.export.format
      output_directory     = format("%s.%s", local.output.root, local.provider.name)
      cpus                 = local.build.vm.cpu
      memory               = local.build.vm.mem
      disk_size            = local.build.vm.disk.size
      boot_command         = local.build.vm.boot.command
      boot_wait            = local.build.vm.boot.wait
      http_directory       = local.build.http.directory
      http_content         = local.build.http.content
      iso_checksum         = local.build.iso.checksum
      iso_url              = local.build.iso.url
      iso_urls             = local.build.iso.urls
      iso_target_path      = local.build.iso.target.path
      iso_target_extension = local.build.iso.target.extension
      shutdown_command     = local.build.vm.shutdown.command
      shutdown_timeout     = local.build.vm.shutdown.timeout
      ssh_username         = local.build.vm.ssh.username
      ssh_password         = local.build.vm.ssh.password
      ssh_wait_timeout     = local.build.vm.ssh.timeout
    }
  }

  provisioner "shell" {
    inline = [
      "if [ -x /usr/share/vagrantry/seal.sh ]; then sudo /usr/share/vagrantry/seal.sh; fi",
      "export HISTSIZE=0",
    ]
  }

  post-processors {
    post-processor "vagrant" {
      compression_level    = 9
      keep_input_artifact  = true
      output               = "${local.output.root}.${local.provider.name}.box"
      vagrantfile_template = local.vagrantfile.template
      provider_override    = local.provider.name
    }
    post-processor "artifice" {
      files = ["${local.output.root}.${local.provider.name}/**"]
    }
    post-processor "compress" {
      output = "${local.output.root}.${local.provider.name}.tar.gz"
    }
    post-processor "artifice" {
      files = [
        "${local.output.root}.${local.provider.name}.box",
        "${local.output.root}.${local.provider.name}.tar.gz",
      ]
    }
    post-processor "checksum" {
      checksum_types = ["sha256"]
      output         = "${local.output.root}.{{.ChecksumType}}sum.txt"
    }
    post-processor "manifest" {
      output     = "${local.output.root}.packer-manifest.json"
      strip_time = true
      custom_data = merge({ provider = local.provider.name },
        { for k, v in local.box : format("box.%s", k) => v if(v != null) },
        try({ "iso.arch" = coalesce(local.iso.arch) }, {}),
        try({ "iso.distro" = coalesce(local.iso.distro) }, {}),
        try({ "iso.edition" = coalesce(local.iso.edition) }, {}),
        try({ "iso.variant" = coalesce(local.iso.variant) }, {}),
        try({ "iso.version" = coalesce(local.iso.version) }, {}),
        try({ "vm.cpu" = coalesce(local.build.vm.cpu) }, {}),
        try({ "vm.mem" = coalesce(local.build.vm.mem) }, {}),
        try({ "vm.type" = coalesce(local.build.vm.type) }, {}),
        try({ "vm.disk.device" = coalesce(local.build.vm.disk.device) }, {}),
        try({ "vm.disk.adapter" = coalesce(local.build.vm.disk.adapter) }, {}),
        try({ "vm.iso.adapter" = coalesce(local.build.vm.iso.adapter) }, {}),
        try({ "vm.net.adapter" = coalesce(local.build.vm.net.adapter) }, {}),
      )
    }
  }
  #  post-processors {
  #    post-processor "artifice" {
  #      files = ["${local.output.root}.${local.provider.name}/**"]
  #    }
  #    post-processor "compress" {
  #      output = "${local.output.root}.${local.provider.name}.tar.gz"
  #    }
  #  }
  #  post-processors {
  #    post-processor "artifice" {
  #      files = [
  #        "${local.output.root}.${local.provider.name}.box",
  #        "${local.output.root}.${local.provider.name}.tar.gz",
  #      ]
  #    }
  #    post-processor "checksum" {
  #      checksum_types = ["sha256"]
  #      output         = "${local.output.root}.{{.ChecksumType}}sum.txt"
  #    }
  #    post-processor "manifest" {
  #      output     = "${local.output.root}.packer-manifest.json"
  #      strip_time = true
  #    }
  #  }
}
