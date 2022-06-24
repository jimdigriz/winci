Create suitable Microsoft Windows images for CI.

## Related Links

 * [packer](https://www.packer.io/docs)
     * [Windows Templates for Packer](https://github.com/StefanScherer/packer-windows)
 * [Answer files](https://docs.microsoft.com/windows-hardware/manufacture/desktop/update-windows-settings-and-scripts-create-your-own-answer-file-sxs)
     * [Unattended Windows Setup Reference](https://docs.microsoft.com/windows-hardware/customize/desktop/unattend/)

## Issues

 * currently only Windows 11 Insider Preview is supported
     * should work with other locales, but untested
 * ...still yet to describe how to use this image (ie. through WinRM and/or OpenSSH) for CI purposes.
 * we assume if running on Linux, SPICE is available
 * find a way to disable Windows Defender from the CLI without a reboot
     * this does *not* work as the 'Tamper Protection' needs to be disabled from meat space:

           powershell.exe -Command "Set-MpPreference -DisableRealTimeMonitoring $true"

     * [...one interesting approach](https://github.com/mandiant/commando-vm/issues/136#issuecomment-674270169)

# Preflight

You will need the following installed:

 * [QEMU (tested with 7.0.0)](https://www.qemu.org/)
     * output of `qemu-system-x86_64 -accel help` must list
         * Linux: `kvm`
         * macOS (Intel): `hvf`
     * if you wish to use non-accelerated (`tcg`) mode, Windows will install and run *really* slowly, but you will also need to uncomment [`winrm_timeout` in `setup.pkr.hcl` and set it to a multi-hour value](https://www.packer.io/plugins/builders/qemu)
 * either:
     * VNC client
     * [SPICE client](https://www.spice-space.org/)
         * though SPICE provides a nicer user experience, it is a lot of work to get SPICE working under macOS so it is recommended you stick with VNC
 * `curl`
 * GNU `make`
     * macOS users will need to run `gmake` where `make` is described instead
 * `m4`
 * `unzip`

Before starting to build the image, you need to download the [Windows 11 Insider Preview ISO (Dev Channel, tested with build 25140, filename `Windows11_InsiderPreview_Client_x64_en-us_25140.iso`)](https://www.microsoft.com/software-download/windowsinsiderpreviewiso) into the top of project directory.

Make sure you have at least 30 GiB of disk space to work with.

# Building

Create the image using:

    make CORES=2 RAM=4096

Where:

 * **`IMAGE` (default: first glob match `Windows11_InsiderPreview_Client_x64_*.iso` in sorted descending order):** ISO image to use
 * **`CORES` (default: `2`, must be more than 1):** number of CPUs to provide to the VM
 * **`RAM` (default: `4096`):** amount of RAM to provide to the VM in MiB
 * **`ACCEL` (default: suitable for your OS):** QEMU accelerator to use
     * **Linux:** `kvm`
     * **macOS:** `hvf`
 * **`SPICE` (default: on Linux `5930`, otherwise `0`):** port to connect on
     * zero (`0`) forcible disables SPICE

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

    make spice SPICE=5930

Where:

 * **`SPICE` (default: `5930`):** port to connect on

# Usage

Once the image has built (typical build time is 30 minutes), the single output artefact is a qcow2 image located at `output-main/packer-main`.

To start a VM using this image, run:

    make vm CORES=2 RAM=4096 VNC=5900 SSH=2222 SPICE=5930 RDP=3389

Points of interest:

 * you will be presented with the [QEMU monitor](https://qemu.readthedocs.io/en/latest/system/monitor.html)
 * you can access the VM either using
     * Graphically
         * your VNC viewer (defaults to `:0` aka port `5900`, or if that is in use increments to the next free port)
         * `make spice` as before
         * use an RDP (Remote Desktop) client pointing at `3389/tcp`
     * Terminal connect over `localhost` (bound to `127.0.0.1`) using `Administrator`/`password` as your credentials
         * WinRM to `5930/tcp`
         * SSH to `2222/tcp`
 * we use the image in 'snapshot' mode with means nothing is persisted back to the image
 * if you wish to persist your changes you should halt (*not* shutdown) your VM and run from the monitor console

       commit all
       quit

 * image has an snapshot called 'initial' which provides you with a point to restore to using

       qemu-img snapshot -a initial output-main/packer-main
