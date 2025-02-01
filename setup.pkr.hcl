variable "iso" {
  type = string
}

variable "iso_virtio" {
  type = string
  default = "virtio-win.iso"
}

variable "accel" {
  type = string
  default = "tcg"
}

# https://www.microsoft.com/en-gb/windows/windows-11-specifications
variable "cores" {
  type = number
  default = 2
}
variable "ram" {
  type = number
  default = 4096
}

variable "vga" {
  type = string
  default = "virtio"
}

variable "spice" {
  type = string
  default = null
}

variable "username" {
  type = string
  default = "Administrator"
}
variable "password" {
  type = string
  default = "password"
}

packer {
  required_plugins {
    qemu = {
      version = "~> 1"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

source "qemu" "main" {
  headless = true

  communicator = "winrm"
  skip_nat_mapping = true
  winrm_username = var.username
  winrm_password = var.password
  #winrm_timeout = "30m"
  shutdown_command = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""

  format = "qcow2"
  # Windows 11 wants at least 52GiB
  disk_size = "60G"
  disk_compression = true
  # we would prefer to do this ourselves to see a progress bar, but packer (1.8.1) ignores this option and eats stdout
  #skip_compaction = true
  qemu_img_args {
    create = [ "-o", "lazy_refcounts=on" ]
    # using one coroutine is 2x faster than any higher value (compression?)
    convert = [ "-o", "lazy_refcounts=on", "-o", "compression_type=zstd" ]
  }

  iso_url = "/dev/null"
  iso_checksum = "none"

  floppy_files = [
    "Autounattend.xml"
  ]
  floppy_dirs = [
    "Autounattend"
  ]

  qemuargs = concat([
    [ "-machine", "q35,accel=${var.accel}" ],
    # Windows 11 requires all these extra CPU flags whilst Windows 10 could just use 'qemu64' alone
    # POPCNT is caught during install, whilst lacking the others will just prevent the install starting and return back to the BIOS screen
    [ "-cpu", "qemu64,+ssse3,+sse4.1,+sse4.2,+popcnt" ],
    [ "-smp", "cpus=${var.cores}" ],
    [ "-m", var.ram ],
    [ "-nodefaults" ],
    [ "-serial", "none" ],
    [ "-parallel", "none" ],
    [ "-vga", var.vga ],
    [ "-device", "virtio-serial-pci" ],
    [ "-netdev", "user,id=user.0,hostfwd=tcp:127.0.0.1:{{ .SSHHostPort }}-:5985" ],
    [ "-device", "virtio-net-pci,netdev=user.0" ],
    [ "-device", "virtio-balloon" ],
    # https://wiki.qemu.org/Features/VirtIORNG
    [ "-device", "virtio-rng-pci,max-bytes=1024,period=1000" ],
    [ "-device", "ahci,id=ahci" ],
    [ "-drive", "if=virtio,file=output/packer-main,discard=unmap,detect-zeroes=unmap,format=qcow2,cache=unsafe" ],
    [ "-drive", "if=none,id=cdrom0,media=cdrom,file=${var.iso},readonly=on" ],
    [ "-device", "ide-cd,drive=cdrom0,bus=ahci.1" ],
    [ "-drive", "if=none,id=cdrom1,media=cdrom,file=${var.iso_virtio},readonly=on" ],
    [ "-device", "ide-cd,drive=cdrom1,bus=ahci.2" ],
    [ "-device", "qemu-xhci" ],
    [ "-device", "usb-tablet" ],
    [ "-device", "usb-kbd" ],
    [ "-boot", "once=d" ]
  ], var.spice == null ? [] : [
    [ "-spice", "unix=on,addr=${var.spice},disable-ticketing=on" ],
    [ "-device", "virtserialport,chardev=spicechannel0,name=com.redhat.spice.0" ],
    [ "-chardev", "spicevmc,id=spicechannel0,name=vdagent" ]
  ])

  output_directory = "output"

  # https://github.com/hashicorp/packer/issues/2648
  # unable to figure out how to serve binary files with http_content
  http_directory = "assets"
}

build {
  sources = ["source.qemu.main"]

  # we push everything into a script as it is faster than a provisioner
  provisioner "windows-shell" {
    script = "setup.bat"
  }
}
