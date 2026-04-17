#!/bin/sh

set -eu

# You will need ~45GiB to *create* the image resulting in the 15GiB .qcow2
# To install/start ISE, the .qcow2 image will inflate to at least 100GiB

cleanup () {
	[ -z "${WORKDIR:-}" ] || rm -rf "$WORKDIR"
	[ -z "${IMAGE_OK:-}" ] || rm -f "$IMAGE"
}
trap cleanup EXIT INT TERM

: ${SOURCE:=Cisco-vISE-300-3.4.0.608.ova}
: ${IMAGE:=Cisco-vISE.qcow2}
[ -f "$IMAGE" ] || {
	[ -f "$SOURCE" ] || {
		echo SOURCE non-existent so unable to build IMAGE >&2
		exit 1
	}
	WORKDIR=$(basename -s .ova "$SOURCE")
	rm -rf "$WORKDIR"
	mkdir "$WORKDIR"
	tar -C "$WORKDIR" -xvf "$SOURCE"
	qemu-img convert -c -o lazy_refcounts=on -o compression_type=zstd -p -f vmdk -O qcow2 "$WORKDIR/${WORKDIR}-disk1.vmdk" "$IMAGE"
	qemu-img snapshot -c zero "$IMAGE"
	rm -rf "$WORKDIR"
}
IMAGE_OK=1

[ "${ACCEL:-}" ] || case "$(uname -s)" in
Linux)	ACCEL=kvm:tcg;;
Darwin)	ACCEL=hcf:tcg;;
esac

# /tmp is usually noexec...unless you are insane...
export TMPDIR="$PWD"

exec qemu-system-x86_64 \
	-machine q35,accel=${ACCEL:-tcg} \
	-cpu qemu64 \
	-smp cpus=${CORES:-4} \
	-m ${RAM:-16384} \
	-nodefaults \
	-serial mon:stdio \
	-parallel none \
	-vga none \
	-device virtio-serial-pci \
	-netdev user,id=user.0,hostfwd=tcp:127.0.0.1:${SSH:-2222}-:22,hostfwd=tcp:127.0.0.1:${HTTPS:-4443}-:443,hostfwd=udp:127.0.0.1:${RADAUTH:-1812}-:1812,hostfwd=tcp:127.0.0.1:${RADAUTH:-1812}-:1812 \
	-device e1000e,netdev=user.0 \
        -device pvscsi,id=scsi \
        -device scsi-hd,drive=hd \
	-drive if=none,id=hd,file=$IMAGE,discard=unmap,detect-zeroes=unmap,format=qcow2,cache=unsafe
