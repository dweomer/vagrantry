iso_distro  = "Tumbleweed"
iso_variant = "MicroOS"
iso_edition = "DVD"
iso_mirrors = [ # https://mirrors.opensuse.org/list/tumbleweed.html
  "_mirror/opensuse/tumbleweed", # local first
  "/srv/mirror/opensuse/tumbleweed", # setup an nfs mount to your nas with mirrored content ...
  "https://download.opensuse.org/tumbleweed",
]
iso_checksum = "file:https://download.opensuse.org/tumbleweed/iso/openSUSE-{VARIANT}-{EDITION}-{ARCH}-{VERSION}-Media.iso.sha256"
iso_url      = "{MIRROR}/iso/openSUSE-{VARIANT}-{EDITION}-{ARCH}-{VERSION}-Media.iso"
iso_arch     = "x86_64"
iso_version  = "Snapshot20211205"

box_arch    = "amd64"
box_guest   = "linux"
box_version = "16.2021.1205"

guest_boot_wait = "10s"
guest_boot_command = [
  "<esc><enter><wait>",
  "linux biosdevname=0 net.ifnames=0 netdevice=eth0 netsetup=dhcp", "<wait>",
  " lang=en_US textmode=1 autoyast=http://{{.HTTPIP}}:{{.HTTPPort}}/autoinst.xml", "<wait>",
  "<enter><wait5>",
]
guest_http_directory = "distro/{DISTRO}/{VARIANT}/http/{PROVIDER}"
guest_types = {
  virtualbox = "OpenSUSE_64"
  vmware     = "opensuse64Guest"
}

