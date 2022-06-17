Create suitable Microsoft Windows images for CI.

**N.B.** currently only Windows 11 Insider Preview is supported

## Related Links

 * [packer](https://www.packer.io/docs)
     * [Windows Templates for Packer](https://github.com/StefanScherer/packer-windows)
 * [Answer files](https://docs.microsoft.com/windows-hardware/manufacture/desktop/update-windows-settings-and-scripts-create-your-own-answer-file-sxs)
     * [Unattended Windows Setup Reference](https://docs.microsoft.com/windows-hardware/customize/desktop/unattend/)

## Issues

 * find a way to disable Windows Defender from the CLI without a reboot
     * this does *not* work as the 'Tamper Protection' needs to be done from meatspace:

           powershell.exe -Command "Set-MpPreference -DisableRealTimeMonitoring $true"

     * [...one interesting approach](https://github.com/mandiant/commando-vm/issues/136#issuecomment-674270169)

# Preflight

You will need the following installed:

 * [QEMU (tested with 7.0.0)](https://www.qemu.org/)
 * [SPICE client](https://www.spice-space.org/)
 * `curl`
 * GNU `make`
     * macOS users will need to run `gmake` where `make` is described instead
 * `m4`
 * `unzip`

Before starting to build the image, you need to download the [Windows 11 Insider Preview ISO (Dev Channel, tested with build 25140)](https://www.microsoft.com/software-download/windowsinsiderpreviewiso) into the top of project directory.

Make sure you have at least 30 GiB of disk space to work with.

# Usage

Create the image using:

    make CORES=2 RAM=4096

Where:

 * **`CORES` (default: `2`, must be more than 1):** number of CPUs to provide to the VM
 * **`RAM` (default: `4096`):** amount of RAM to provide to the VM in MiB
 * **`ACCEL` (default: suitable for your OS):** QEMU accelerator to use
     * **Linux:** `kvm`
     * **macOS:** `hvf`

**N.B.** to see detailed debugging, set the environment variable `PACKER_LOG=1`

Whilst the build runs, you can connect with:

    make spice SPICE=5930

Where:

 * **`SPICE` (default: `5930`):** port to connect on

Once the image has built (at least 30 minutes), you will be left with a qcow2 image at `output-main/packer-main`.

To start a VM using this image, run:

    make vm CORES=2 RAM=4096 SPICE=5930

Points of interest:

 * you will be presented with the [QEMU monitor](https://qemu.readthedocs.io/en/latest/system/monitor.html)
 * you can access the VM via `make spice` as before
 * image has an snapshot called 'initial' which provides you with a point to restore to
 * we use the image in 'snapshot' mode with means nothing is persisted back to the image
 * if you wish to persist your changes you should halt (*not* shutdown) your VM and run from the monitor console

       commit all
       quit
