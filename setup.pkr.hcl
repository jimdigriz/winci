variable "iso_url" {
  type = string
}

variable "iso_url_virtio" {
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
  type = list(list(string))
  default = []
}

variable "username" {
  type = string
  default = "Administrator"
}
variable "password" {
  type = string
  default = "password"
}

source "qemu" "main" {
  headless = true

  communicator = "winrm"
  winrm_username = var.username
  winrm_password = var.password
  #winrm_timeout = 10m
  shutdown_command = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""

  format = "qcow2"
  disk_size = "40960M"
  disk_compression = true
  # we would prefer to do this ourselves to see a progress bar, but packer (1.8.1) ignores this option and eats stdout
  #skip_compaction = true
  qemu_img_args {
    create = [ "-o", "lazy_refcounts=on,preallocation=metadata" ]
    # using one coroutine is 2x faster than any higher value (compression?)
    convert = [ "-o", "lazy_refcounts=on", "-m", "1" ]
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
    [ "-smp", "cpus=${var.cores}" ],
    [ "-cpu", "qemu64" ],
    [ "-m", "${var.ram}" ],
    [ "-nodefaults" ],
    [ "-serial", "none" ],
    [ "-parallel", "none" ],
    [ "-vga", var.vga ],
    [ "-netdev", "user,id=user.0,hostfwd=tcp:127.0.0.1:{{ .SSHHostPort }}-:5985" ],
    [ "-device", "virtio-net-pci,netdev=user.0" ],
    [ "-device", "virtio-balloon" ],
    [ "-device", "ahci,id=ahci" ],
    [ "-drive", "if=virtio,file=output-main/packer-main,discard=unmap,detect-zeroes=unmap,format=qcow2,cache=unsafe" ],
    [ "-drive", "if=none,id=cdrom0,media=cdrom,file=${var.iso_url},readonly=on" ],
    [ "-device", "ide-cd,drive=cdrom0,bus=ahci.1" ],
    [ "-drive", "if=none,id=cdrom1,media=cdrom,file=${var.iso_url_virtio},readonly=on" ],
    [ "-device", "ide-cd,drive=cdrom1,bus=ahci.2" ],
    [ "-device", "qemu-xhci" ],
    [ "-device", "usb-tablet" ],
    [ "-device", "usb-kbd" ],
    [ "-boot", "once=d" ]
  ], var.spice)
 }

build {
  sources = ["source.qemu.main"]

  # we push everything into a script as it is faster than a provisioner
  provisioner "windows-shell" {
    script = "setup.bat"
  }
}
