SHELL = /bin/sh
.DELETE_ON_ERROR:

COMMITID = $(shell git rev-parse --short HEAD | tr -d '\n')$(shell git diff-files --quiet || printf -- -dirty)

PACKER_VERSION = 1.8.1

define BUILD_FLAGS_template =
PACKER_BUILD_FLAGS += -var $(1)=$(2)
endef
#$(eval $(call BUILD_FLAGS_template,commit,$(COMMITID)))

KERNEL = $(shell uname -s | tr A-Z a-z)
MACHINE = $(shell uname -m)
ifeq ($(MACHINE),x86_64)
MACHINE = amd64
endif

CURL = curl -fRL --compressed -C - --retry 3 -o $(2) $(3) $(1)

VIRTIO_URL ?= https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso
IMAGE ?= $(lastword $(sort $(wildcard Windows11_InsiderPreview_Client_x64_*.iso)))
ifeq ($(IMAGE),)
$(error download an ISO from https://www.microsoft.com/software-download/windowsinsiderpreviewiso)
endif
LOCALE ?= $(word 5,$(subst _, ,$(IMAGE)))

OBJS = $(IMAGE) Autounattend.xml $(wildcard Autounattend/*) virtio-win.iso

CLEAN =
DISTCLEAN =

.PHONY: all
all: vm

.PHONY: clean
clean:
	rm -rf $(CLEAN)

.PHONY: distclean
distclean: clean
	rm -rf $(DISTCLEAN)

.PHONY: notdirty
notdirty:
ifneq ($(findstring -dirty,$(COMMITID)),)
ifeq ($(IDDQD),)
	@{ echo 'DIRTY DEPLOYS FORBIDDEN, REJECTING DEPLOY DUE TO UNCOMMITED CHANGES' >&2; git status; exit 1; }
else
	@echo 'DIRTY DEPLOY BUT GOD MODE ENABLED' >&2
endif
endif

virtio-win.iso:
	$(call CURL,$(VIRTIO_URL),$@)
DISTCLEAN += virtio-win.iso

hda.qcow2: output-main/packer-main
	qemu-img convert -p -c -O qcow2 $< $@
	qemu-img snapshot -c initial hda.qcow2
CLEAN += hda.qcow2

%: %.m4
	m4 -D LOCALE=$(LOCALE) -D COMMITID=$(COMMITID) $< > $@
CLEAN += Autounattend.xml

output-main/packer-main: PACKER_BUILD_FLAGS += -var iso_url='$(IMAGE)'
output-main/packer-main: PACKER_BUILD_FLAGS += -var iso_url_virtio='virtio-win.iso'
output-main/packer-main: setup.pkr.hcl .stamp.packer $(OBJS)
	env TMPDIR=$(CURDIR) ./packer build -on-error=ask -only qemu.main $(PACKER_BUILD_FLAGS) $<
CLEAN += output-main/packer-main

.PHONY: vm
vm: SPICE ?= 5930
vm: WINRM ?= 5985
vm: hda.qcow2
	env TMPDIR='$(PWD)' qemu-system-x86_64 \
		-cpu qemu64
		-nodefaults \
		-serial none \
		-parallel none \
		-vga qxl \
		-device virtio-serial-pci \
		-spice addr=127.0.0.1,port=$(SPICE),disable-ticketing=on \
		-device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 \
		-chardev spicevmc,id=spicechannel0,name=vdagent \
		-netdev user,id=user.0,hostfwd=tcp:127.0.0.1:$(WINRM)-:5985 \
		-device virtio-balloon \
		-device ahci,id=ahci \
		-drive if=virtio,file=$<,discard=unmap,detect-zeroes=unmap,snapshot=on,format=qcow2 \
		-drive if=none,id=cdrom0,media=cdrom,readonly=on \
		-device ide-cd,drive=cdrom0,bus=ahci.1 \
		-device qemu-xhci \
		-device usb-tablet \
		-device usb-kbd

.PHONY: spice
spice: SPICE ?= 5930
spice:
	spicy -h 127.0.0.1 -p $(SPICE)

packer_$(PACKER_VERSION)_$(KERNEL)_$(MACHINE).zip:
	curl -f -O -J -L https://releases.hashicorp.com/packer/$(PACKER_VERSION)/$@
DISTCLEAN += $(wildcard packer_*.zip)

packer: packer_$(PACKER_VERSION)_$(KERNEL)_$(MACHINE).zip
	unzip -oDD $< $@
CLEAN += packer

.stamp.packer: setup.pkr.hcl packer $(OBJS)
	./packer init $<
	./packer validate $(PACKER_BUILD_FLAGS) $<
	@touch $@
CLEAN += .stamp.packer
