# Using Cisco ISE in a VM

Though not complete within this project, within the [`vm.sh` script](./vm.sh) is the process on running Cisco ISE within a QEMU VM.

This was tested with:

 * `Cisco-vISE-300-3.4.0.608.ova`
 * ...and also after applying `ise-patchbundle-3.4.0.608-Patch1-24121602.SPA.x86_64.tar.gz`

**N.B.** this was using a [time limited 'free' download](https://software.cisco.com/download/home/283801620/type) option

Credentials:

  * **username:** `admin`
  * **password:** `Password123!`

Networking uses [Userspace SLIRP](https://wiki.qemu.org/Documentation/Networking#User_Networking_(SLIRP)):

 * **guest network:** `10.0.2.15/24`
 * **gateway (and host) address on guest network:** `10.0.2.2`
 * **DNS resolver on guest network:** `10.0.2.3`
