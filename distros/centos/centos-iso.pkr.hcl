variable "iso_arch" {
  default = "x86_64"
}

variable "iso_version" {
  type    = string
  default = null
}

variable "iso_edition" {
  type    = string
  default = null
}

variable "iso_vault_checksum_file" {
  type    = string
  default = null
}

variable "iso_mirrors" {
  default = [
    "http://centos-distro.cavecreek.net/centos",
    "http://mirror.rackspace.com/CentOS",
    "http://mirror.arizona.edu/centos",
    "http://ftp.osuosl.org/pub/centos",
    "http://linuxsoft.cern.ch/centos-vault",
    "http://mirror.nsc.liu.se/centos-store",
    "http://ftp.iij.ad.jp/pub/linux/centos",
    "http://ftp.iij.ad.jp/pub/linux/centos-vault",
    "http://archive.kernel.org/centos",
    "http://archive.kernel.org/centos-vault",
    "https://vault.centos.org",
  ]
  description = "Visit http://isoredirect.centos.org/centos/7/isos/x86_64/ to see the mirrors closest to you"
}

variable "iso_checksums" {
  default = {
    "8.4.2105" : {
      "x86_64" : {
        "boot" : "sha256:c79921e24d472144d8f36a0d5f409b12bd016d9d7d022fd703563973ca9c375c",
        "dvd1" : "sha256:0394ecfa994db75efc1413207d2e5ac67af4f6685b3b896e2837c682221fd6b2",
      },
      "aarch64" : {
        "boot" : "sha256:106d9ce13076441c52dc38c95e9977a83f28a4c1ce88baa10412c1e3cc9b2a2b",
        "dvd1" : "sha256:6654112602beec7f6b5c134f28cf6b77aedc05b2a7ece2656dacf477f77c81df",
      },
    },
    "8.3.2011" : {
      "x86_64" : { # https://vault.centos.org/8.3.2011/isos/x86_64/CHECKSUM
        "boot" : "sha256:2b801bc5801816d0cf27fc74552cf058951c42c7b72b1fe313429b1070c3876c",
        "dvd1" : "sha256:aaf9d4b3071c16dbbda01dfe06085e5d0fdac76df323e3bbe87cce4318052247",
        "minimal" : "sha256:191daa949a021733bbc19ae42dd1280b30d4ded7e316733461a2efb4463fbfed",
      },
      "aarch64" : { # https://vault.centos.org/8.3.2011/isos/aarch64/CHECKSUM
        "boot" : "sha256:b87fc578c53b541229883d391d1299b9d2a051c1f33dc15052dc42ed941600a9",
        "dvd1" : "sha256:ecf586b30fa16b28a33b2fb4ffadd8801201608f9755c94da1212876d32fba92",
        "minimal" : "sha256:5492a9d99d8c58db3d0c81b8acdda2ec60b451a63f8daf7eb6c0fcd208cca456",
      },
    },
    "8.2.2004" : {
      "x86_64" : { # https://vault.centos.org/8.2.2004/isos/x86_64/CHECKSUM
        "boot" : "sha256:c67876a5602faa17f68b40ccf2628799b87454aa67700f0f57eec15c6ccdd98c",
        "dvd1" : "sha256:c87a2d81d67bbaeaf646aea5bedd70990078ec252fc52f5a7d65ff609871e255",
        "minimal" : "sha256:47ab14778c823acae2ee6d365d76a9aed3f95bb8d0add23a06536b58bb5293c0",
      },
      "aarch64" : { # https://vault.centos.org/8.2.2004/isos/aarch64/CHECKSUM
        "boot" : "sha256:76a9a5f84ac9581fee079d7154bf68f72661c9d941e9ab3143bccc760c23eecc",
        "dvd1" : "sha256:9d2f066edfc3820fc9e4c6d52f01489a3ed57515cf608773e2b8a04f1903c838",
        "minimal" : "sha256:621d08902bfd7ca8437cd536b86631c87ddc3e36a530abc77011d230401eb158",
      },
    },
    "8.1.1911" : {
      "x86_64" : { # https://vault.centos.org/8.1.1911/isos/x86_64/CHECKSUM
        "boot" : "sha256:7fea13202bf2f26989df4175aace8fdc16e1137f7961c33512cbfad844008948",
        "dvd1" : "sha256:3ee3f4ea1538e026fff763e2b284a6f20b259d91d1ad5688f5783a67d279423b",
        "minimal" : "sha256:00000000000000000000000000000000000000000000000000000000deadbeef", # missing
      },
      "aarch64" : { # https://vault.centos.org/8.1.1911/isos/aarch64/CHECKSUM
        "boot" : "sha256:e693b670b841d0270a393ed27b97c7efc054dc791e9e0fd77fb813c9cf4b760b",
        "dvd1" : "sha256:357f34e86a28c86aaf1661462ef41ec4cf5f58c120f46e66e1985a9f71c246e3",
        "minimal" : "sha256:00000000000000000000000000000000000000000000000000000000deadbeef", # missing
      },
    },
    "8.0.1905" : {
      "x86_64" : { # https://vault.centos.org/8.0.1905/isos/x86_64/CHECKSUM
        "boot" : "sha256:a7993a0d4b7fef2433e0d4f53530b63c715d3aadbe91f152ee5c3621139a2cbc",
        "dvd1" : "sha256:ea17ef71e0df3f6bf1d4bf1fc25bec1a76d1f211c115d39618fe688be34503e8",
      },
      "aarch64" : { # https://vault.centos.org/8.0.1905/isos/aarch64/CHECKSUM
        "boot" : "sha256:18a211a826bd3dd4d034ddc529303bc2b5dc6e1b63ea311644d7698e7b67fb3e",
        "dvd1" : "sha256:c950cf7599a2317e081506a3e0684f665ef9c8fe66963bf7492595d7c6ccc230",
      },
    },
    "7.9.2009" : {
      "x86_64" : {
        "DVD" : "sha256:e33d7b1ea7a9e2f38c8f693215dd85254c3a4fe446f93f563279715b68d07987",
        "Everything" : "sha256:689531cce9cf484378481ae762fae362791a9be078fda10e4f6977bf8fa71350",
        "Minimal" : "sha256:07b94e6b1a0b0260b94c83d6bb76b26bf7a310dc78d7a9c7432809fb9bc6194a",
        "NetInstall" : "sha256:b79079ad71cc3c5ceb3561fff348a1b67ee37f71f4cddfec09480d4589c191d6",
      },
      "aarch64" : {
        "Everything" : "file:http://ftp.osuosl.org/pub/centos-altarch/7.9.2009/isos/aarch64/sha256sum.txt",
        "Minimal" : "file:http://ftp.osuosl.org/pub/centos-altarch/7.9.2009/isos/aarch64/sha256sum.txt",
        "NetInstall" : "file:http://ftp.osuosl.org/pub/centos-altarch/7.9.2009/isos/aarch64/sha256sum.txt",
      },
    },
    "7.8.2003" : {
      "x86_64" : { # https://vault.centos.org/7.8.2003/isos/x86_64/sha256sum.txt
        "DVD" : "sha256:087a5743dc6fd6706d9b961b8147423ddc029451b938364c760d75440eb7be14",
        "Everything" : "sha256:4120aff542c2f9a30bcf90d4d79e39511e5d9eabdf202566a94ff24ea7f0974c",
        "LiveGNOME" : "sha256:3febddab1498f940e3127f2f5e1056d6fef57fcd559d5b70ff1bfa55a444f176",
        "LiveKDE" : "sha256:92be566a5b1d2aa62acf2e4ab01ba91420e7170cdb21e2e190dd1dafcb6a8c94",
        "Minimal" : "sha256:659691c28a0e672558b003d223f83938f254b39875ee7559d1a4a14c79173193",
        "NetInstall" : "sha256:101bc813d2af9ccf534d112cbe8670e6d900425b297d1a4d2529c5ad5f226372",
      },
    },
    "7.7.1908" : {
      "x86_64" : { # https://vault.centos.org/7.7.1908/isos/x86_64/sha256sum.txt
        "DVD" : "sha256:9bba3da2876cb9fcf6c28fb636bcbd01832fe6d84cd7445fa58e44e569b3b4fe",
        "Everything" : "sha256:bd5e6ca18386e8a8e0b5a9e906297b5610095e375e4d02342f07f32022b13acf",
        "LiveGNOME" : "sha256:ba827210d4eb9313fc19120b9b85e7baef234c7f81bc55847a336114ddac20cb",
        "LiveKDE" : "sha256:0ef3310d13f7fc140ec5180dc05369d2f473e802577466825205d17e46ef5a9b",
        "Minimal" : "sha256:9a2c47d97b9975452f7d582264e9fc16d108ed8252ac6816239a3b58cef5c53d",
        "NetInstall" : "sha256:6ffa7ad44e8716e4cd6a5c3a85ba5675a935fc0448c260f43b12311356ba85ad",
      },
    },
    "7.6.1810" : {
      "x86_64" : { # https://vault.centos.org/7.6.1810/isos/x86_64/sha256sum.txt
        "DVD" : "sha256:6d44331cc4f6c506c7bbe9feb8468fad6c51a88ca1393ca6b8b486ea04bec3c1",
        "Everything" : "sha256:918975cdf947e858c9a0c77d6b90a9a56d9977f3a4496a56437f46f46200cf71",
        "LiveGNOME" : "sha256:3213b2c34cecbb3bb817030c7f025396b658634c0cf9c4435fc0b52ec9644667",
        "LiveKDE" : "sha256:87623c8ab590ad0866c5f5d86a2d7ed631c61d69f38acc42ce2c8ddec65ecea2",
        "Minimal" : "sha256:38d5d51d9d100fd73df031ffd6bd8b1297ce24660dc8c13a3b8b4534a4bd291c",
        "NetInstall" : "sha256:19d94274ef856c4dfcacb2e7cfe4be73e442a71dd65cc3fb6e46db826040b56e",
      },
    },
  }
}

variable "iso_target_path" {
  type    = string
  default = null
}

variable "iso_target_extension" {
  type    = string
  default = "iso"
}

local "iso" {
  expression = {
    arch    = var.iso_arch
    edition = coalesce(var.iso_edition, "dvd1")
    version = coalesce(var.iso_version, "8.4.2105")
    target = {
      path      = var.iso_target_path
      extension = var.iso_target_extension
    }
    vault = {
      checksum_file = coalesce(var.iso_vault_checksum_file, local.semver_major == "7" ? "sha256sum.txt" : "CHECKSUM")
    }
  }
}
