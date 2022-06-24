Exposing the wired interface for 802.1X testing.

The container runs `hostapd` alongside `qemu`, listing on the second network network card and sending RADIUS packets to a server of your choosing.

# Build

    docker build -t winci-dot1x examples/dot1x

# Run

    docker run -it --rm \
    	--device /dev/net/tun:/dev/net/tun \
    	--device /dev/kvm:/dev/kvm \
    	--cap-add SYS_ADMIN --cap-add NET_ADMIN \
    	-v /path/to/img.qcow2:/hda.qcow2:ro \
    	-e AUTHADDR=192.0.2.100 -e AUTHPORT=1812 -e AUTHSECRET=testing123 \
    	-p 2222:22 -p 5985:5985 -p 5900:5900 -p 5930:5930 -p 5555:5555 -p 3389:3389 \
    	winci-dot1x

**N.B.** `5555/tcp` is the QEMU monitor which you can use `telnet` to interact with

# Test

...
