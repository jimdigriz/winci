Windows 11 Insider builder, suitable for testing as part of your project...

## Related Links

 * [Answer files](https://docs.microsoft.com/windows-hardware/manufacture/desktop/update-windows-settings-and-scripts-create-your-own-answer-file-sxs)
 * [Unattended Windows Setup Reference](https://docs.microsoft.com/windows-hardware/customize/desktop/unattend/)

## Issues

 * `Autounattend.xml`:
     * WinPE:
         * would be nice to get rid of the delayed ten second restart
 * `setup.bat`:
     * unable to figure out how to get `/exe:lzx` to work with `compact.exe`

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

    make CORES=2 RAM=4096

Where:

 * **`CORES` (default: `2`):** number of CPUs to provide to the VM
 * **`RAM` (default: `4096`):** amount of RAM to provide to the VM in MiB
