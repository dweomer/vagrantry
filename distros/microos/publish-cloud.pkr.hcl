packer {
  required_plugins {
    vagrant = {
      # necessary for uploading box checksums via vagrant-cloud api, see:
      # - https://github.com/hashicorp/packer-plugin-vagrant/pull/32
      version = "1.0.1-dweomer-pr-32"
      source  = "github.com/dweomer/vagrant"
    }
  }
}

variable "cloud_org" {
  type = string
  default = env("VAGRANTRY_CLOUD_ORG")
}

variable "cloud_tag" {
  type = string
  default = env("VAGRANTRY_CLOUD_TAG")
}

variable "cloud_url" {
  type = string
  default = env("VAGRANTRY_CLOUD_URL")
}

local "cloud" {
  expression = {
    publish = contains(["cloud", "vagrant", "vagrant-cloud"], local.publish.scheme) ? ["publish-cloud"] : [],
    provider_aliases = {
      vmware = "vmware_desktop",
    },
    provider_files = zipmap(
      [for box in local.publish.box_files : replace(replace(box, "${local.output.root}.", ""), ".box", "")],
      convert(local.publish.box_files, list(string)),
    )
#    target = regex(
#      "(?P<box_org>[a-z][a-z0-9]*)(?:[/](?P<box_name>.*?))?(?:[,](?P<box_version>[\\^,]*))?(?:[,][a-z][a-z0-9]*[:][/][/](?P<box_download_root>.*))?$",
#      local.publish.target,
#    )
    target = {
      box_org = var.cloud_org
      box_name = var.cloud_tag
      box_version = local.build.version
      box_download_root = length(var.cloud_url) == 0 ? null : var.cloud_url
    }
  }
}

local "cloud-checksum-file" {
  expression = try(element(convert(local.publish.checksum_files, list(string)), 0), null)
}

local "cloud-box" {
  expression = {
    org = coalesce(
      local.cloud.target.box_org, "unknown",
    )
    name = coalesce(
      try(local.cloud.target.box_name, null),
      format("microos-%s", local.arch),
    )
    version = coalesce(
      try(local.cloud.target.box_version, null),
      local.semver_str,
    )
    providers = { for name, file in local.cloud.provider_files : name => {
      file = file,
      url = try(
        format("%s/microos/%s/%s/%s.%s.box",
          local.cloud.target.box_download_root,
          urlencode(local.semver_major),
          urlencode(local.arch),
          urlencode(local.vm.name),
          name,
      ), null),
      name = lookup(local.cloud.provider_aliases, name, name),
      checksum = try(lookup(
        { for check in [for line in split("\n", chomp(file(abspath(local["cloud-checksum-file"])))) : split("\t", line)] : check[1] => check[0] },
      basename(file), ""), null),
    } },
  }
}

local "cloud-box-checksums" {
  expression = try({ for check in [for line in split("\n", chomp(file(abspath(local["cloud-checksum-file"])))) : split("\t", line)] : check[1] => check[0] }, {})
}

local "cloud-box-tag" {
  expression = try(format("%s/%s", local["cloud-box"].org, local["cloud-box"].name), null)
}

source "null" "cloud" {
  communicator = "none"
}

build {
  dynamic "source" {
    labels   = ["null.cloud"]
    for_each = try(var.verbose, false) && local.publish.manifest_file != null ? local.cloud.publish : []
    content {
      name = "publish-debug"
    }
  }
  provisioner "shell-local" {
    inline_shebang = "/usr/bin/env bash"
    inline = flatten([
      ["set -eu -o pipefail"],
      "echo 'PUBLISH-SCHEME: ${local.publish.scheme}'",
      "echo 'PUBLISH-TARGET: ${local.publish.target}'",
      "echo 'PUBLISH-TARGET-PARSED: ${jsonencode(local.cloud.target)}'",
      "echo 'PUBLISH-MANIFEST: ${local.publish.manifest_file}'",
      formatlist("echo 'PUBLISH-CHECKSUM: %s'", local.publish.checksum_files),
      formatlist("echo 'PUBLISH-BOX-FILE: %s'", local.publish.box_files),
    ])
  }
}

build {
  // to enable this publisher: `packer build --parallel-builds=1 --var publish=vagrant-cloud://box-org[/box-name][,box-version-override][,box-download-root-url] <vars-and-flags> .`
  dynamic "source" {
    labels   = ["null.cloud"]
    for_each = local.cloud.publish
    content {
      name = source.value
    }
  }
  post-processor "shell-local" {
    inline_shebang = "/usr/bin/env bash"
    inline = flatten([
      ["set -eu -o pipefail"],
      "echo 'VAGRANT-CLOUD-BOX-TAG: ${local["cloud-box-tag"]}'",
      "echo 'VAGRANT-CLOUD-BOX-VERSION: v${local["cloud-box"].version}'",
    ])
  }
  dynamic "post-processors" {
    for_each = try(local["cloud-box"].providers, [])
    content {
      post-processor "shell-local" {
        inline = flatten([
          "echo 'VAGRANT-CLOUD-BOX-PROVIDER: ${jsonencode(post-processors.value.name)}'",
          "echo 'VAGRANT-CLOUD-BOX-FILE: ${post-processors.value.file}'",
          "echo 'VAGRANT-CLOUD-BOX-CHECKSUM: ${jsonencode(post-processors.value.checksum)}'",
          "echo 'VAGRANT-CLOUD-BOX-URL: ${jsonencode(post-processors.value.url)}'",
        ])
      }
      post-processor "artifice" {
        files = [post-processors.value.file]
      }
      post-processor "vagrant-cloud" {
        no_release       = false
        box_tag          = local["cloud-box-tag"]
        box_download_url = post-processors.value.url
        box_checksum     = "sha256:${post-processors.value.checksum}"
        version          = local["cloud-box"].version
      }
    }
  }
}
