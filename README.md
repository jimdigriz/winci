Build Microsoft Windows images for QEMU to run for the purposes of continuous integration (CI) including the VirtIO drivers and remote access enabled (WinRM, SSH and RDP).

This work was sponsored by [InkBridge Networks](https://inkbridgenetworks.com/).

## Issues

 * ...still yet to describe how to use this image (ie. through WinRM and/or OpenSSH) for CI purposes
 * find a way to disable Windows Defender from the CLI without a reboot
     * this does *not* work as the 'Tamper Protection' needs to be disabled from meat space:

           powershell.exe -Command "Set-MpPreference -DisableRealTimeMonitoring $true"

     * [...one interesting approach](https://github.com/mandiant/commando-vm/issues/136#issuecomment-674270169)
     * [...and another](https://x.com/jonasLyk/status/1293815234805760000)

# Preflight

You will need the following installed:

 * [QEMU (tested with 7.2)](https://www.qemu.org/)
     * output of `qemu-system-x86_64 -accel help` must list
         * Linux: `kvm`
         * macOS (Intel): `hvf`
     * if you wish to use non-accelerated (`tcg`) mode, Windows will install and run *really* slowly, but you will also need to uncomment [`winrm_timeout` in `setup.pkr.hcl` and set it to a multi-hour value](https://www.packer.io/plugins/builders/qemu)
 * either:
     * VNC client
     * [SPICE client](https://www.spice-space.org/)
         * though SPICE provides a nicer user experience, it is a lot of work to get SPICE working under macOS so it is recommended you stick with VNC
 * `m4`

You will also require the following assets:

 * [Packer](https://developer.hashicorp.com/packer) installed (linked from above) and available in your local path
    * tested with version 1.12.0
 * placed at the top of the project directory, either a [Windows 10 or 11](https://www.microsoft.com/en-gb/software-download) or [Insider Preview](https://www.microsoft.com/en-us/software-download/windowsinsiderpreviewiso) ISO
    * tested with:
       * Windows 11: `Win11_24H2_EnglishInternational_x64.iso` and `Windows11_InsiderPreview_Client_x64_en-gb_26100.1150.iso`
       * Windows 10: `Win10_22H2_EnglishInternational_x64v1.iso` and `Windows10_InsiderPreview_Client_x64_en-gb_19045.1826.iso`
 * [Windows VirtIO Drivers ('stable' recommended) ISO](https://github.com/virtio-win/virtio-win-pkg-scripts) download page
    * tested with version 0.1.240
    * [versions later than 0.1.240 (confirmed also with 0.1.266) seem not to work](https://github.com/virtio-win/virtio-win-guest-tools-installer/issues/64)
       * version 0.1.266: drivers install but running either virtio-win-gt-x64 or virtio-win-guest-tools just stalls
 * [Win32-OpenSSH](https://github.com/PowerShell/Win32-OpenSSH) 64bit MSI
    * tested with version v9.8.1.0p1-Preview (`OpenSSH-Win64-v9.8.1.0.msi`)

Make sure you have at least 30 GiB of disk space to work with.

# Building

Create the image using:

    rm -rf output
    env IMAGE=... CORES=2 RAM=4096 sh build.sh

Where:

 * **`IMAGE` (required):** ISO image to use
     * examples are `Win11_24H2_EnglishInternational_x64.iso`, `Windows11_InsiderPreview_Client_x64_en-gb_26100.1150.iso`
 * **`VIRTIO` (default `virtio-win.iso`):** VirtIO driver ISO image to use
 * **`CORES` (default: `2`, must be more than 1):** number of CPUs to provide to the VM
 * **`RAM` (default: `4096`):** amount of RAM to provide to the VM in MiB
 * **`ACCEL` (default: suitable for your OS):** QEMU accelerator to use
     * **Linux:** `kvm:tcg`
     * **macOS:** `hvf:tcg`
 * **`PASSWORD` (default: `password`):** password for `Administrator` account
 * **`SPICE` (default: disabled):** enable spice on UNIX socket name such as `spice.sock`

**N.B.** to see detailed debugging, set the environment variable `PACKER_LOG=1`

## Monitoring the Build

If you wish to use VNC (for example if you are a macOS user) then you should look in the `packer` console output for:

    ...
    qemu.main: The VM will be run headless, without a GUI. If you want to
    qemu.main: view the screen of the VM, connect via VNC without a password to
    qemu.main: vnc://127.0.0.1:5909
    ...

Then point your VNC client at the `proto://host:port` it lists; the example here shows `vnc://127.0.0.1:5909` so you could connect with:

    vncviewer 127.0.0.1:5909

Or:

    vncviewer :5909

Or:

    vncviewer :9

### SPICE

For a better and faster experience, you should use SPICE which you can connect with:

    remote-viewer spice+unix://spice.sock

**N.B.** less CPU usage if you disable compression (`--spice-preferred-compression=off`)

Or alternatively (though [not recommended](https://www.spice-space.org/spice-user-manual.html#spice-client)):

    spicy --uri spice+unix://spice.sock

### Troubleshooting

If the build fails for some reasons, you should [open a command prompt (`Shift-F10`) and use Notepad to read some `.log` or `.xml` files](https://learn.microsoft.com/en-us/answers/questions/242735/windows-10-unattended-install-log-file-location).

# Usage

Once the image has built (typical build time is 30 minutes), the single output artefact is a qcow2 image located at `output/packer-main`.

To start a VM using this image, run:

    env IMAGE=... CORES=2 RAM=4096 sh vm.sh

Where:

 * **`IMAGE` (default `output/packer-main`):** point to the QCOW2 image to use as the main disk
 * **`CORES`/`RAM`/`ACCEL`/`SPICE`:** as above for `build.sh`
 * **`VNC` (default: `5900`):** port to listen for VNC connections
 * **`WINRM` (default: 5985`):** port to listen for WinRM connections
 * **`RDP` (default: `3389`):** port to listen for RDP (remote desktop) connections
 * **`SSH` (default: `2222`):** port to listen for SSH connections
    * connect using something like:

          ssh -o PasswordAuthentication=yes -p 2222 Administrator@localhost

Points of interest:

 * you will be presented with the [QEMU monitor](https://qemu.readthedocs.io/en/master/system/monitor.html)
 * if SCP does not work for you, try including the `-O` parameter to [use the legacy SCP protocol which seems to work](https://github.com/PowerShell/Win32-OpenSSH/issues/1945#issuecomment-1311251741)
 * image is used in 'snapshot' mode which means nothing is persisted back to the image
    * if you wish to persist your changes you should halt (*not* shutdown) your VM and run from the monitor console

          commit all
          quit

 * image has an snapshot called 'initial' which provides you with a point to restore to using

       qemu-img snapshot -a initial output/packer-main

## Examples

 * [802.1X](./examples/dot1x)
