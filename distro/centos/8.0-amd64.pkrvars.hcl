iso_distro  = "CentOS"
iso_edition = "dvd1"
iso_mirrors = [ # http://isoredirect.centos.org/centos/8/isos/x86_64/
  "_mirror/centos", # local first
  "/srv/mirror/centos", # setup an nfs mount to your nas with mirrored content ...
  "https://download-ib01.fedoraproject.org/pub/centos",
  "https://download-ib01.fedoraproject.org/pub/centos-altarch",
  "https://mirror.arizona.edu/centos",
  "https://ftp.osuosl.org/pub/centos",
  "https://mirror.nsc.liu.se/centos-store",
  "https://linuxsoft.cern.ch/centos-vault",
  "https://ftp.iij.ad.jp/pub/linux/centos",
  "https://ftp.iij.ad.jp/pub/linux/centos-vault",
  "https://archive.kernel.org/centos",
  "https://archive.kernel.org/centos-vault",
  "https://vault.centos.org",
]
iso_checksum = "sha256:ea17ef71e0df3f6bf1d4bf1fc25bec1a76d1f211c115d39618fe688be34503e8"
iso_url      = "{MIRROR}/{VERSION}/isos/{ARCH}/{DISTRO}-8-{ARCH}-1905-{EDITION}.iso"
iso_arch     = "x86_64"
iso_version  = "8.0.1905"

box_arch    = "amd64"
box_guest   = "linux"
box_version = "8.0.1905"

guest_boot_wait = "10s"
guest_boot_command = [
  "<esc><wait>",
  "linux biosdevname=0 net.ifnames=0", "<wait>",
  " inst.ks=http://{{.HTTPIP}}:{{.HTTPPort}}/kickstart.cfg", "<wait>",
  "<enter><wait5>",
]
guest_http_directory = "distro/{DISTRO}/http/8/{PROVIDER}"
guest_types = {
  virtualbox = "RedHat_64"
  vmware     = "centos8_64Guest"
}
