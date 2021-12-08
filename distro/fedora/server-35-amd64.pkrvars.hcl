iso_distro  = "Fedora"
iso_variant = "Server"
iso_edition = "dvd"
iso_mirrors = [ # https://admin.fedoraproject.org/mirrormanager/mirrors/Fedora/35
  "_mirror/fedora", # local first
  "/srv/mirror/fedora", # setup an nfs mount to your nas with mirrored content ...
  "https://dl.fedoraproject.org/pub/fedora",
  "https://mirror.arizona.edu/fedora",
]
iso_checksum = "sha256:3fe521d6c7b12c167f3ac4adab14c1f344dd72136ba577aa2bcc4a67bcce2bc6"
iso_url      = "{MIRROR}/linux/releases/35/{VARIANT}/{ARCH}/iso/{DISTRO}-{VARIANT}-{EDITION}-{ARCH}-{VERSION}.iso"
iso_arch     = "x86_64"
iso_version  = "35-1.2"

box_arch    = "amd64"
box_guest   = "linux"
box_version = "35.1.2"

guest_boot_wait = "10s"
guest_boot_command = [
  "<esc><wait>",
  "linux biosdevname=0 net.ifnames=0", "<wait>",
  " inst.ks=http://{{.HTTPIP}}:{{.HTTPPort}}/kickstart.cfg","<wait>",
  "<enter><wait5>",
]
guest_http_directory = "distro/{DISTRO}/{VARIANT}/http/35/{PROVIDER}"
guest_types = {
  virtualbox = "RedHat_64"
  vmware     = "fedora64Guest"
}
