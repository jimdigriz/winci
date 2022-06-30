FROM debian:bullseye-slim

SHELL ["/bin/sh", "-x", "-c"]

RUN apt-get update \
	&& apt-get -y upgrade --no-install-recommends \
	&& apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" \
		--option=Dpkg::options::=--force-unsafe-io install --no-install-recommends \
			hostapd \
			iproute2 \
			m4 \
			supervisor \
			qemu-system-x86 \
	&& apt-get -y autoremove \
	&& apt-get clean \
	&& find /var/lib/apt/lists -type f -delete

RUN sed -i -e 's/^\(\[supervisord\]\)$/\1\nnodaemon=true/' /etc/supervisor/supervisord.conf
ADD supervisor.conf.d/ /etc/supervisor/conf.d/
ADD hostapd.conf.m4 /etc/hostapd/hostapd.conf.m4

EXPOSE 22/tcp 3389/tcp 5555/tcp 5900/tcp 5930/tcp 5985/tcp

ENTRYPOINT [ "/usr/bin/supervisord" ]
CMD [ "-c", "/etc/supervisor/supervisord.conf" ]
