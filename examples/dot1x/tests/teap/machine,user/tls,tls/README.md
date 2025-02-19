This test does not work as:

 * user TLS componment is backed by a Smartcard
 * [QEMU emulates a Smartcard](https://www.qemu.org/docs/master/system/devices/ccid.html)
    * Windows supports the emulated Smartcard *reader*, it does not support the emulated Smartcard it-self
    * OpenSC seems to be able to talk to it, but it was non-obvious how to get this working
       * it could see 'John Doe' but it could not initialise the card claiming to be unsupported
 * neither the Smartcard CA or client certificate has been added to FreeRADIUS's configuration to validate

If someone has the answer here on how to resolve this, do let me know.

I got as far as setting up and plumbing the Smartcard into the VM, using the following process.

To configure the Smartcard emulation you will need `certutil` (from the Debian/Ubuntu package `libnss3-tools`) and then run:

    mkdir nssdb
    certutil -N -d sql:nssdb --empty-password
    dd if=/dev/urandom count=20 2>/dev/null \
    	| certutil -S -d sql:nssdb -z /dev/stdin -s "CN=Fake Smart Card CA" -x -t TC,TC,TC -n fake-smartcard-ca -m 0
    dd if=/dev/urandom count=20 2>/dev/null \
    	| certutil -S -d sql:nssdb -z /dev/stdin -t ,, -s "CN=John Doe" -n id-cert -c fake-smartcard-ca -m 1
    dd if=/dev/urandom count=20 2>/dev/null \
    	| certutil -S -d sql:nssdb -z /dev/stdin -t ,, -s "CN=John Doe (signing)" --nsCertType smime -n signing-cert -c fake-smartcard-ca -m 2
    dd if=/dev/urandom count=20 2>/dev/null \
    	| certutil -S -d sql:nssdb -z /dev/stdin -t ,, -s "CN=John Doe (encryption)" --nsCertType sslClient -n encryption-cert -c fake-smartcard-ca -m 3

Then start the VM using:

    env TEST=teap/machine,user/tls,tls ... sh run.sh \
    	-usb \
    	-device usb-ccid \
    	-device ccid-card-emulated,backend=certificates,db=sql:nssdb,cert1=id-cert,cert2=signing-cert,cert3=encryption-cert

This will then perform the machine authentication, and when starting the user authentication a popup appears on Windows explaining that the Smartcard does not contain usable materials.
