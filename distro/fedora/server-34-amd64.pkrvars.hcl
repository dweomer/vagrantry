iso_distro  = "Fedora"
iso_variant = "Server"
iso_edition = "dvd"
iso_mirrors = [ # https://admin.fedoraproject.org/mirrormanager/mirrors/Fedora/34
  "_mirror/centos", # local first
  "/srv/mirror/centos", # setup an nfs mount to your nas with mirrored content ...
  "https://dl.fedoraproject.org/pub/fedora",
  "https://mirror.arizona.edu/fedora",
]
iso_checksum = "sha256:0b9dc87d060c7c4ef89f63db6d4d1597dd3feaf4d635ca051d87f5e8c89e8675"
iso_url      = "{MIRROR}/linux/releases/34/{VARIANT}/{ARCH}/iso/{DISTRO}-{VARIANT}-{EDITION}-{ARCH}-{VERSION}.iso"
iso_arch     = "x86_64"
iso_version  = "34-1.2"

box_arch    = "amd64"
box_guest   = "linux"
box_version = "34.1.2"

guest_boot_wait = "10s"
guest_boot_command = [
  "<esc><wait>",
  "linux biosdevname=0 net.ifnames=0", "<wait>",
  " inst.ks=http://{{.HTTPIP}}:{{.HTTPPort}}/kickstart.cfg","<wait>",
  "<enter><wait5>",
]
guest_http_directory = "distro/{DISTRO}/{VARIANT}/http/34/{PROVIDER}"
guest_types = {
  virtualbox = "RedHat_64"
  vmware     = "fedora64Guest"
}
