variable "iso_url" {
  type = string
}

variable "iso_url_virtio" {
  type = string
  default = "virtio-win.iso"
}

source "qemu" "main" {
  headless = true
  disable_vnc = true

  communicator = "winrm"
  winrm_username = "Administrator"
  winrm_password = "password"
  shutdown_command = "C:\\windows\\system32\\sysprep\\sysprep.exe /generalize /oobe /shutdown /quiet"

  # https://www.microsoft.com/en-gb/windows/windows-11-specifications
  machine_type = "q35"
  cpus = 2
  memory = 4096
  
  firmware = "/usr/share/OVMF/OVMF_CODE.fd"
  use_pflash = true

  format = "qcow2"
  disk_size = "40960M"

  iso_url = "/dev/null"
  iso_checksum = "none"

  floppy_files = [
    "Autounattend.xml"
  ]
  floppy_dirs = [
    "Autounattend"
  ]

  qemuargs = [
    [ "-cpu", "qemu64" ],
    [ "-nodefaults" ],
    [ "-serial", "none" ],
    [ "-parallel", "none" ],
    [ "-vga", "qxl" ],
     [ "-device", "virtio-serial-pci" ],
     [ "-spice", "addr=127.0.0.1,port=5930,disable-ticketing=on" ],
     [ "-device", "virtserialport,chardev=spicechannel0,name=com.redhat.spice.0" ],
     [ "-chardev", "spicevmc,id=spicechannel0,name=vdagent" ],
    [ "-netdev", "user,id=user.0,hostfwd=tcp:127.0.0.1:{{ .SSHHostPort }}-:5985" ],
    [ "-device", "virtio-balloon" ],
    [ "-device", "ahci,id=ahci" ],
    [ "-drive", "if=virtio,file=output-main/packer-main,discard=unmap,detect-zeroes=unmap,format=qcow2" ],
    [ "-drive", "if=none,id=cdrom0,media=cdrom,file=${var.iso_url},readonly=on" ],
    [ "-device", "ide-cd,drive=cdrom0,bus=ahci.1" ],
    [ "-drive", "if=none,id=cdrom1,media=cdrom,file=${var.iso_url_virtio},readonly=on" ],
    [ "-device", "ide-cd,drive=cdrom1,bus=ahci.2" ],
    [ "-device", "qemu-xhci" ],
    [ "-device", "usb-tablet" ],
    [ "-device", "usb-kbd" ],
    [ "-boot", "once=d" ]
  ]
 }

build {
  sources = ["source.qemu.main"]

  provisioner "windows-shell" {
    inline = [
      "E:\\virtio-win-gt-x64.msi /quiet /passive /norestart",
      "E:\\virtio-win-guest-tools.exe /quiet /passive /norestart",

      # no need to hibernate in a VM
      "powercfg.exe /hibernate off"
    ]
  }

  provisioner "powershell" {
    inline = [
      "Optimize-Volume -Verbose -DriveLetter C -Defrag",
      "Optimize-Volume -Verbose -DriveLetter C -SlabConsolidate",
      # no need to run ReTrim as both DeFrag and SlabConsolidate run it as a post operation
      #"Optimize-Volume -Verbose -DriveLetter C -ReTrim"
    ]
  }
}
