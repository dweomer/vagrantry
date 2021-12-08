iso_distro  = "CentOS"
iso_edition = "Minimal"
iso_mirrors = [ # http://isoredirect.centos.org/centos/7/isos/x86_64/
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
iso_checksum = "sha256:07b94e6b1a0b0260b94c83d6bb76b26bf7a310dc78d7a9c7432809fb9bc6194a"
iso_url      = "{MIRROR}/{VERSION}/isos/{ARCH}/{DISTRO}-7-{ARCH}-{EDITION}-2009.iso"
iso_arch     = "x86_64"
iso_version  = "7.9.2009"

box_arch    = "amd64"
box_guest   = "linux"
box_version = "7.9.2009"

guest_boot_wait = "10s"
guest_boot_command = [
  "<esc><wait>",
  "linux biosdevname=0 net.ifnames=0", "<wait>",
  " inst.ks=http://{{.HTTPIP}}:{{.HTTPPort}}/kickstart.cfg", "<wait>",
  "<enter><wait5>",
]
guest_http_directory = "distro/{DISTRO}/http/7/{PROVIDER}"
guest_types = {
  virtualbox = "RedHat_64"
  vmware     = "centos7_64Guest"
}
