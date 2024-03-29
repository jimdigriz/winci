SHELL = /bin/sh
.DELETE_ON_ERROR:

COMMITID = $(shell git rev-parse --short HEAD | tr -d '\n')$(shell git diff-files --quiet || printf -- -dirty)

PACKER_VERSION = 1.9.1

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
IMAGE ?= $(lastword $(sort $(wildcard Win11_*_x64*.iso Windows11_*_x64*.iso)))
ifeq ($(IMAGE),)
$(error download an ISO from https://www.microsoft.com/software-download/windowsinsiderpreviewiso or https://www.microsoft.com/software-download/windows10ISO)
endif
ifeq ($(findstring Win10,$(IMAGE)),)
VERSION ?= $(word 6,$(subst _, ,$(basename $(IMAGE))))
LOCALE ?= $(word 5,$(subst _, ,$(basename $(IMAGE))))
else
VERSION ?= $(word 2,$(subst _, ,$(basename $(IMAGE))))
LOCALE ?= en-us
endif

ifeq ($(KERNEL),linux)
ACCEL ?= kvm:tcg
else ifeq ($(KERNEL),darwin)
ACCEL ?= hvf:tcg
else
ACCEL ?= tcg
endif
RAM ?= 4096
CORES ?= 2

ifeq ($(KERNEL),linux)
SPICE ?= 5930
endif
ifeq ($(SPICE),)
SPICE ?= 0
endif

USERNAME ?= Administrator
$(eval $(call BUILD_FLAGS_template,username,$(USERNAME)))

PASSWORD ?= password
$(eval $(call BUILD_FLAGS_template,password,$(PASSWORD)))

OBJS = $(IMAGE) Autounattend.xml $(wildcard Autounattend/*)

CLEAN =
DISTCLEAN = assets

.PHONY: all
all: output-main/packer-main

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
OBJS += virtio-win.iso

# see setup.bat
assets/OpenSSH-Win64.msi: URI ?= https://github.com/PowerShell/Win32-OpenSSH/releases/download/v8.9.1.0p1-Beta/OpenSSH-Win64-v8.9.1.0.msi
assets/OpenSSH-Win64.msi:
	@mkdir -p $(@D)
	$(call CURL,$(URI),$@)
OBJS += assets/OpenSSH-Win64.msi

# see setup.bat for reason why this is commented out
#SDelete.zip:
#	$(call CURL,https://download.sysinternals.com/files/SDelete.zip,$@)
#DISTCLEAN += SDelete.zip
#
#assets/sdelete64.exe: SDelete.zip
#	unzip -oDD -d $(@D) $< $(@F)
#CLEAN += assets/sdelete64.exe
#OBJS += assets/sdelete64.exe

Autounattend.xml: DEFINES += USERNAME=$(USERNAME)
Autounattend.xml: DEFINES += PASSWORD=$(PASSWORD)
Autounattend.xml: DEFINES += VERSION=$(VERSION)
Autounattend.xml: DEFINES += LOCALE=$(LOCALE)
Autounattend.xml: DEFINES += COMMITID=$(word 1,$(subst -, ,$(COMMITID)))
ifeq ($(findstring Win10,$(IMAGE)),)
Autounattend.xml: DEFINES += WINVER=11
else
Autounattend.xml: DEFINES += WINVER=10
endif
Autounattend.xml: Autounattend.xml.m4
	m4 $(foreach D,$(DEFINES),-D $(D)) $< > $@
CLEAN += Autounattend.xml

output-main/packer-main: PACKER_BUILD_FLAGS += -var iso_url='$(IMAGE)'
output-main/packer-main: PACKER_BUILD_FLAGS += -var iso_url_virtio=virtio-win.iso
output-main/packer-main: PACKER_BUILD_FLAGS += -var accel=$(ACCEL)
output-main/packer-main: PACKER_BUILD_FLAGS += -var ram=$(RAM)
output-main/packer-main: PACKER_BUILD_FLAGS += -var cores=$(CORES)
ifeq ($(SPICE),0)
output-main/packer-main: PACKER_BUILD_FLAGS += -var vga=virtio
else
output-main/packer-main: PACKER_BUILD_FLAGS += -var vga=qxl
output-main/packer-main: PACKER_BUILD_FLAGS += -var spice='[ [ "-device", "virtio-serial-pci" ], [ "-spice", "addr=127.0.0.1,port=$(SPICE),disable-ticketing=on" ], [ "-device", "virtserialport,chardev=spicechannel0,name=com.redhat.spice.0" ], [ "-chardev", "spicevmc,id=spicechannel0,name=vdagent" ] ]'
endif
output-main/packer-main: setup.pkr.hcl .stamp.packer $(OBJS) | notdirty
	env TMPDIR=$(CURDIR) ./packer build -on-error=ask -only qemu.main $(PACKER_BUILD_FLAGS) $<
	qemu-img snapshot -c initial $@
CLEAN += output-main

.PHONY: vm
vm: VNC ?= 5900
ifeq ($(SPICE),0)
vm: VGA ?= virtio
else
vm: VGA ?= qxl
vm: SPICE_ARGS += -spice addr=127.0.0.1,port=$(SPICE),disable-ticketing=on
vm: SPICE_ARGS += -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0
vm: SPICE_ARGS += -chardev spicevmc,id=spicechannel0,name=vdagent
endif
vm: SSH ?= 2222
vm: WINRM ?= 5985
vm: RDP ?= 3389
vm: output-main/packer-main
	env TMPDIR='$(PWD)' qemu-system-x86_64 \
		-machine q35,accel=$(ACCEL) \
		-cpu qemu64 \
		-smp cpus=$(CORES) \
		-m $(RAM) \
		-nodefaults \
		-serial none \
		-parallel none \
		-vga $(VGA) \
		-vnc 127.0.0.1:$(shell expr $(VNC) - 5900) \
		-device virtio-serial-pci $(SPICE_ARGS) \
		-netdev user,id=user.0,hostfwd=tcp:127.0.0.1:$(SSH)-:22,hostfwd=tcp:127.0.0.1:$(WINRM)-:5985,hostfwd=tcp:127.0.0.1:$(RDP)-:3389 \
		-device virtio-net-pci,netdev=user.0 \
		-device virtio-balloon \
		-device ahci,id=ahci \
		-drive if=virtio,file=$<,discard=unmap,detect-zeroes=unmap,snapshot=on,format=qcow2,cache=unsafe \
		-drive if=none,id=cdrom0,media=cdrom,readonly=on \
		-device ide-cd,drive=cdrom0,bus=ahci.1 \
		-device qemu-xhci \
		-device usb-tablet \
		-device usb-kbd \
		-monitor stdio

.PHONY: spice
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
