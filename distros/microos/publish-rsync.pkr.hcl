local "rsync" {
  expression = {
    publish = local.publish.scheme == "rsync" ? ["publish-rsync"] : []
  }
}

source "null" "rsync" {
  communicator = "none"
}

build {
  // to enable this publisher: `packer build --parallel-builds=1 --var publish=rsync://user@host:some/upload/directory/ <vars-and-flags> .`
  dynamic "source" {
    labels   = ["null.rsync"]
    for_each = local.rsync.publish
    content {
      name = source.value
    }
  }
  provisioner "shell-local" {
    inline_shebang = "/usr/bin/env bash"
    inline = ["set -eux -o pipefail",
      format("rsync -amv --relative %s/ %s",
        join("/", [var.output_directory, local.build.timestamp, ".", "microos", local.semver_major, local.arch]),
        coalesce(local.publish.target),
      ),
    ]
  }
}
