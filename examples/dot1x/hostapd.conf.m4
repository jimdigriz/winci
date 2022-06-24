logger_syslog=-1
logger_syslog_level=2
logger_stdout=-1
logger_stdout_level=2

ctrl_interface=/var/run/hostapd

ctrl_interface_group=0

driver=wired
interface=tap0
ieee8021x=1

use_pae_group_addr=1

own_ip_addr=192.0.2.1

nas_identifier=hostapd

auth_server_addr=ADDR
auth_server_port=PORT
auth_server_shared_secret=SECRET
