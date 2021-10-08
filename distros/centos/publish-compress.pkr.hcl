local "compress" {
  expression = {
    publish = local.publish.scheme == "compress" ? ["publish-compress"] : []
  }
}

source "null" "compress" {
  communicator = "none"
}

build {
  // to enable this publisher: `packer build --parallel-builds=1 --var publish=compress://[zstd|gzip] <vars-and-flags> .`
  dynamic "source" {
    labels   = ["null.compress"]
    for_each = local.compress.publish
    content {
      name = source.value
    }
  }
  provisioner "shell-local" {
    inline_shebang = "/usr/bin/env bash"
    inline = flatten([
      ["set -eux -o pipefail"],
      formatlist(format("%s %%s", local.publish.target == "zstd" ? "zstd --rm --no-progress" : "gzip -9"), local.publish.tar_files),
    ])
  }
}
