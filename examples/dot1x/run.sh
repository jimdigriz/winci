#!/bin/sh

set -eu

# deps for debian:bookworm-slim
# apt install --no-install-recommends \
#	build-essential \
#	ca-certificates \
#	git \
#	libssl-dev \
#	libtalloc-dev \
#	sshpass \
#	qemu-system

: ${ADDR:=127.0.0.1}
: ${PORT:=1812}
: ${SECRET:=testing123}

: ${FREERAD_GIT:=https://github.com/FreeRADIUS/freeradius-server.git}
: ${FREERAD_REF:=v3.2.x}

: ${HOSTAPD_GIT:=https://w1.fi/hostap.git}
: ${HOSTAPD_REF:=main}

JOBS=$(($(getconf _NPROCESSORS_ONLN) + 1))
IFACE=winci-dot1x
MON=qemu-monitor

cleanup () {
	[ ! -p "$MON" ] || {
		echo quit >&9
		exec 9>&-
		rm -f "$MON"
	}

	[ -z "${FREERAD:-}" ] || {
		./freeradius-server/scripts/bin/radmin -f radiusd.sock -e terminate >/dev/null 2>&1
		while kill -0 $FREERAD 2>/dev/null; do sleep 0.5; done
	}

	[ -z "${HOSTAPD:-}" ] || {
		sudo kill -TERM $HOSTAPD
		while kill -0 $HOSTAPD 2>/dev/null; do sleep 0.5; done
		rm -f hostapd.conf
	}

	sudo ip link del $IFACE 2>/dev/null || true
}
trap cleanup EXIT INT TERM

test -f "freeradius-server/.stamp_$FREERAD_REF" || {
	rm -rf freeradius-server
	git clone --no-tags --depth 1 --single-branch --branch "$FREERAD_REF" "$FREERAD_GIT"
	( cd freeradius-server && ./configure --enable-developer )
	make -C freeradius-server -j $JOBS
	make -C freeradius-server/raddb/certs
	sed -ie 's/^\(\s\+socket\) = .*/\1 = radiusd.sock/; s/^#\?\(\s\+mode\) = .*/\1 = rw/' freeradius-server/raddb/sites-available/control-socket
	ln -s -t freeradius-server/raddb/sites-enabled ../sites-available/control-socket
	sed -ie '/^#\?bob\s/ { s/^#//; n; s/^#//; n; s/^#// }' freeradius-server/raddb/mods-config/files/authorize
	touch "freeradius-server/.stamp_$FREERAD_REF"
}
test -f "hostap/.stamp_$HOSTAPD_REF" || {
	git clone --no-tags --depth 1 --single-branch --branch "$HOSTAPD_REF" "$HOSTAPD_GIT"
#	sed -e 's/^#\?\(CONFIG_DRIVER_WIRED\)=.*/\1=y/; s/^#\?\(CONFIG_DRIVER_NL80211.*\)/#\1/; s/^#\?\(CONFIG_DRIVER_NONE\)=.*/\1=y/; s/^#\?\(CONFIG_TESTING_OPTIONS\)=.*/\1=y/' hostap/hostapd/defconfig > hostap/hostapd/.config
	sed -e 's/^#\?\(CONFIG_DRIVER_WIRED\)=.*/\1=y/; s/^#\?\(CONFIG_DRIVER_NL80211.*\)/#\1/; s/^#\?\(CONFIG_DRIVER_NONE\)=.*/\1=y/; s/^#\?\(CONFIG_EAP_TEAP\)=.*/\1=y/; s/^#\?\(CONFIG_TESTING_OPTIONS\)=.*/\1=y/' hostap/hostapd/defconfig > hostap/hostapd/.config
	make -C hostap/hostapd -j $JOBS
	touch "hostap/.stamp_$HOSTAPD_REF"
}

rm -rf logs
mkdir logs

sudo ip tuntap add $IFACE mode tap user $USER
sudo ip link set dev $IFACE up

mkdir logs/hostapd
m4 -DGROUP=$(id -g) -DIFACE=$IFACE -DADDR=$ADDR -DPORT=$PORT -DSECRET=$SECRET hostapd.conf.m4 > hostapd.conf
sudo ./hostap/hostapd/hostapd hostapd.conf > logs/hostapd/stdout &
HOSTAPD=$!

mkdir logs/radiusd
env SSLKEYLOGFILE=logs/radiusd/sslkey.log ./freeradius-server/scripts/bin/radiusd -X > logs/radiusd/stdout &
FREERAD=$!

mkfifo "$MON"
/bin/sh ../../vm.sh \
	-netdev tap,id=user.1,ifname=$IFACE,script=no,downscript=no \
	-device virtio-net-pci,netdev=user.1 <"$MON" >/dev/null &
QEMU=$!
exec 9>> "$MON"
# initially unplug NIC
echo set_link user.1 off >&9

SSHARGS="-o ConnectTimeout=3 -o Port=2222 -o User=Administrator -o PasswordAuthentication=yes"
guest_ssh () {
	env SSHPASS=${PASSWORD:-password} sshpass -e ssh $SSHARGS localhost "$@"
}
guest_scp () {
	env SSHPASS=${PASSWORD:-password} sshpass -e scp $SSHARGS "$@"
}
# wait for the VM to be ready
while ! guest_ssh echo >/dev/null 2>&1; do sleep 1; done
# start dot1x
guest_ssh sc config dot3svc start=demand
guest_ssh sc start dot3svc
# install certificates
guest_scp freeradius-server/raddb/certs/ca.der freeradius-server/raddb/certs/client.p12 localhost:Desktop/
guest_ssh certutil.exe -addstore Root Desktop/ca.der
guest_ssh certutil.exe -p whatever -importpfx Desktop/client.p12

# install profile
CAHASH=$(openssl dgst -sha1 -c freeradius-server/raddb/certs/ca.der | sed -e 's/.*= //; s/:/ /g')
SERVERNAMES=$(openssl x509 -noout -subject -in freeradius-server/raddb/certs/server.pem | sed -e 's/.* CN = \([^,]\+\).*/\1/')
m4 -DCAHASH="$CAHASH" -DSERVERNAMES="$SERVERNAMES" tests/eap-ttls/pap/Ethernet.xml.m4 > Ethernet.xml
guest_scp Ethernet.xml tests/eap-ttls/pap/Credentials.xml localhost:Desktop/
guest_ssh 'netsh lan add profile interface="Ethernet 2" filename="Desktop/Ethernet.xml"'
guest_ssh 'netsh lan set eapuserdata interface="Ethernet 2" filename="Desktop/Credentials.xml" allusers=yes'
rm Ethernet.xml

# turn on the NIC to kick off the authentication
echo set_link user.1 on >&9

sleep inf

exit 0
