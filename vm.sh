#!/bin/sh

set -eu

IMAGE=output/packer-main
[ -f "$IMAGE" ] || {
	echo IMAGE non-existent >&2
	exit 1
}

[ "${ACCEL:-}" ] || case "$(uname -s)" in
Linux)	ACCEL=kvm:tcg;;
Darwin)	ACCEL=hcf:tcg;;
esac

# support screen resizing (virtio seems not to work)
VGA=qxl

# /tmp is usually noexec...unless you are insane...
export TMPDIR="$PWD"

exec qemu-system-x86_64 \
	-machine q35,accel=${ACCEL:-tcg} \
	-cpu qemu64,+ssse3,+sse4.1,+sse4.2,+popcnt \
	-smp cpus=${CORES:-2} \
	-m ${RAM:-4096} \
	-nodefaults \
	-serial none \
	-parallel none \
	-vga ${VGA:-virtio} \
	-device virtio-serial-pci \
	-vnc 127.0.0.1:$((${VNC_PORT:-5900} - 5900)) \
	-netdev user,id=user.0,hostfwd=tcp:127.0.0.1:${SSH_PORT:-2222}-:22,hostfwd=tcp:127.0.0.1:${WINRM_PORT:-5985}-:5985,hostfwd=tcp:127.0.0.1:${RDP_PORT:-3389}-:3389 \
	-device virtio-net-pci,netdev=user.0 \
	-device virtio-balloon \
	-device virtio-rng-pci,max-bytes=1024,period=1000 \
	-device ahci,id=ahci \
	-drive if=virtio,file=output/packer-main,discard=unmap,detect-zeroes=unmap,format=qcow2,cache=unsafe \
	-drive if=none,id=cdrom0,media=cdrom,readonly=on \
	-device ide-cd,drive=cdrom0,bus=ahci.1 \
	-device qemu-xhci \
	-device usb-tablet \
	-device usb-kbd \
	-monitor stdio \
	${SPICE:+-spice unix=on,addr=${SPICE},disable-ticketing=on -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 -chardev spicevmc,id=spicechannel0,name=vdagent}
