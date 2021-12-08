iso_distro  = "CentOS"
iso_edition = "minimal"
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
iso_checksum = "sha256:191daa949a021733bbc19ae42dd1280b30d4ded7e316733461a2efb4463fbfed"
iso_url      = "{MIRROR}/{VERSION}/isos/{ARCH}/{DISTRO}-{VERSION}-{ARCH}-{EDITION}.iso"
iso_arch     = "x86_64"
iso_version  = "8.3.2011"

box_arch    = "amd64"
box_guest   = "linux"
box_version = "8.3.2011"

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
