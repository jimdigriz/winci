Create suitable Microsoft Windows images for CI.

**N.B.** currently only Windows 11 Insider Preview is supported

## Related Links

 * [packer](https://www.packer.io/docs)
     * [Windows Templates for Packer](https://github.com/StefanScherer/packer-windows)
 * [Answer files](https://docs.microsoft.com/windows-hardware/manufacture/desktop/update-windows-settings-and-scripts-create-your-own-answer-file-sxs)
     * [Unattended Windows Setup Reference](https://docs.microsoft.com/windows-hardware/customize/desktop/unattend/)

## Issues

 * `Autounattend.xml`:
     * WinPE:
         * would be nice to get rid of the delayed ten second restart
 * `setup.bat`:
     * unable to figure out how to get `/exe:lzx` to work with `compact.exe`
     * find a way to disable Windows Defender from the CLI without a reboot
     * is `sdelete` worth it?
         * we already defrag/retrim
         * number of blocks used by the sparse file does not change much after the process

# Preflight

 * download the [Windows 11 Insider Preview ISO (Dev Channel, tested with build 25140)](https://www.microsoft.com/software-download/windowsinsiderpreviewiso) into the top of project directory
 * [QEMU (tested with 7.0.0)](https://www.qemu.org/)
 * [SPICE client](https://www.spice-space.org/)
 * GNU `make`
     * macOS users will need to run `gmake` where `make` is described instead
 * `m4`
 * `curl`
 * `unzip`

# Usage

    make hda.qcow2 CORES=2 RAM=4096

Where:

 * **`CORES` (default: `2`):** number of CPUs to provide to the VM
 * **`RAM` (default: `4096`):** amount of RAM to provide to the VM in MiB
 * **`ACCEL` (default: suitable for your OS):** QEMU accelerator to use
     * **Linux:** `kvm`
     * **macOS:** `hvf`

**N.B.** to see detailed debugging, set the environment variable 'PACKER_LOG=1'

Whilst the build runs, you can connect with:

    make spice SPICE=5930

Where:

 * **`SPICE` (default: `5930`):** port to connect on

Once the image has built (at least 30 minutes), you can run it with:

    make vm CORES=2 RAM=4096 SPICE=5930
