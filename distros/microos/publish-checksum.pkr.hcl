local "checksum" {
  expression = {
    publish = local.publish.scheme == "checksum" ? ["publish-checksum"] : []
  }
}

source "null" "checksum" {
  communicator = "none"
}

build {
  // to enable this publisher: `packer build --parallel-builds=1 --var publish=checksum://[sha256|sha384|sha512] <vars-and-flags> .`
  dynamic "source" {
    labels   = ["null.checksum"]
    for_each = local.checksum.publish
    content {
      name = source.value
    }
  }
  post-processors {
    post-processor "artifice" {
      files = flatten([
        fileset(abspath("."), "${local.output.root}.*.box"),
        fileset(abspath("."), "${local.output.root}.*.tar*")
      ])
    }
    post-processor "checksum" {
      checksum_types = [local.publish.target]
      output         = "${local.output.root}.{{.ChecksumType}}sum.txt"
    }
  }
}
