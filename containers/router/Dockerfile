FROM haxagon/workstation-sysbox:27022025

RUN apt-get update -y && apt-get install isc-dhcp-server vsftpd apache2 netcat-traditional -y

# isc-dhcp-server setup
COPY dhcpconfig/isc-dhcp-server /etc/default/isc-dhcp-server
COPY dhcpconfig/dhcpd.conf /etc/dhcp/dhcpd.conf

# FTP setup
RUN mkdir -p /srv/ftp
COPY flag.txt /srv/ftp/flag.txt
RUN chown -R root:root /srv/ftp && chmod a-w /srv/ftp && chown ftp:ftp /srv/ftp/flag.txt
