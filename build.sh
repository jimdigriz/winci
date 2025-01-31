#!/bin/sh

set -eu

win11_locale () {
	case "$(echo $1 | cut -d _ -f 3)" in
	English)		echo en-us;;
	EnglishInternational)	echo en-gb;;
	*)			echo unable to determine locale Windows >&2; exit 1;;
	esac
}

[ -f "${IMAGE:-}" ] || {
	echo IMAGE either not set or non-existent >&2
	exit 1
}
_IMAGE=$(basename "$IMAGE")
case "$_IMAGE" in
# main
Win11_*)	WINVER=11
		VERSION=$(echo $_IMAGE | cut -d _ -f 2)
		LOCALE=$(win11_locale $_IMAGE)
		;;
Win10_*)	WINVER=10
		VERSION=$(echo $_IMAGE | cut -d _ -f 2)
		LOCALE=$(win11_locale $_IMAGE)
		;;
# insider preview
Windows11_*)	WINVER=11;
		VERSION=$(echo $_IMAGE | cut -d _ -f 6 | cut -d . -f 1-2)
		LOCALE=$(echo $_IMAGE | cut -d _ -f 5)
		;;
Windows10_*)	WINVER=10;
		VERSION=$(echo $_IMAGE | cut -d _ -f 6 | cut -d . -f 1-2)
		LOCALE=$(echo $_IMAGE | cut -d _ -f 5)
		;;
*)		echo unable to determine version of Windows >&2;
		exit 1
		;;
esac

: ${VIRTIO:=virtio-win.iso}
[ -f "$VIRTIO" ] || {
	echo VIRTIO either not set or non-existent >&2
	exit 1
}

WINSSH=$(find . -mindepth 1 -maxdepth 1 -type f -name 'OpenSSH-Win64-v*.msi' | sort -r | head -n 1)
[ "$WINSSH" ] || {
	echo "unable to find 'OpenSSH-Win64-v*.msi'" >&2
	exit 1
}
rm -rf assets
mkdir -p assets
ln $WINSSH assets/OpenSSH-Win64.msi

[ "${ACCEL:-}" ] || case "$(uname -s)" in
Linux)	ACCEL=kvm:tcg;;
Darwin)	ACCEL=hcf:tcg;;
esac

# support screen resizing (virtio seems not to work)
VGA=qxl

set -- 	-only=qemu.main \
	-var iso="$IMAGE" \
	-var iso_virtio="$VIRTIO" \
	${ACCEL:+-var accel=$ACCEL} \
	${CORES:+-var cores=$CORES} \
	${RAM:+-var ram=$RAM} \
	${VGA:+-var vga=$VGA} \
	${SPICE:+-var spice=$SPICE}

m4 \
		-D WINVER=$WINVER \
		-D VERSION=$VERSION \
		-D LOCALE=$LOCALE \
		-D COMMITID=$(git rev-parse --short HEAD)$(git diff-files --quiet || printf -- D) \
		-D PASSWORD=${PASSWORD:-password} \
	Autounattend.xml.m4 > Autounattend.xml

# /tmp is usually noexec...unless you are insane...
export TMPDIR="$PWD"

packer init setup.pkr.hcl

packer validate "$@" setup.pkr.hcl

packer build -on-error=ask "$@" setup.pkr.hcl

qemu-img snapshot -c initial output/packer-main

exit 0
