variable "publish" {
  type    = string
  default = null
}

variable "verbose" {
  type    = bool
  default = true
}

local "publish" {
  expression = merge(
    try(
      regex("^(?P<scheme>[a-z][a-z0-9+-.]*)(?:[:][/][/](?P<target>.*))?$", var.publish),
      { scheme = "unknown", target = "/dev/null" },
    ),
    {
      box_files      = fileset(abspath("."), "${local.output.root}.*.box")
      tar_files      = fileset(abspath("."), "${local.output.root}.*.tar")
      checksum_files = fileset(abspath("."), "${local.output.root}.*sum.txt")
      manifest_file = try(
        element(convert(fileset(abspath("."), "${local.output.root}.*-manifest.json"), list(string)), 0), null
      )
    },
  )
}
