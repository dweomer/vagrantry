local "s3" {
  expression = {
    publish = local.publish.scheme == "s3" ? ["publish-s3"] : []
  }
}

source "null" "s3" {
  communicator = "none"
}

build {
  // to enable this publisher: `packer build --parallel-builds=1 --var publish=s3://some-bucket/some/upload/directory/ <vars-and-flags> .`
  dynamic "source" {
    labels   = ["null.s3"]
    for_each = local.s3.publish
    content {
      name = source.value
    }
  }
  provisioner "shell-local" {
    inline_shebang = "/usr/bin/env bash"
    inline = ["set -eux -o pipefail",
      format("aws s3 sync --acl public-read --size-only %s s3://%s",
        join("/", [var.output_directory, local.build.timestamp, ".", "fedora", local.iso.version, local.arch]),
        join("/", [local.publish.target, "fedora", local.iso.version, local.arch]),
      ),
    ]
  }
}
