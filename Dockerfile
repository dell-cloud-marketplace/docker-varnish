FROM ubuntu:trusty
MAINTAINER Dell Cloud Market Place <Cloud_Marketplace@dell.com>

# Update the package repository and install applications
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get -y install gettext
RUN apt-get -y install varnish=3.0.5-2
RUN apt-get -y clean

# The default IP and port of the host to have cache acceleration.
# (172.17.42.1 = docker0 interface)
ENV VARNISH_BACKEND_IP 172.17.42.1
ENV VARNISH_BACKEND_PORT 8080

# The size of the cache eg 100M = 100 Megabytes or 1G = 1 Gigabyte
ENV VARNISH_STORAGE_AMOUNT 100M

# Idle timeout for persistent sessions
ENV VARNISH_SESS_TIMEOUT 20

# The default configuration template will be copied to the config folder, in
# script start.sh, if it doesn't exist. Note: the template is a VCL file which
# allows environmental variables.
RUN mkdir /etc/varnish/config
RUN rm /etc/varnish/default.vcl # Installed by default and not used.
ADD default.template /etc/varnish/default.template

# The port on which Varnish will listen.
ENV VARNISH_PORT 80
EXPOSE 80

# We can specify our own config.template via this volume.
VOLUME ["/etc/varnish/config"]

ADD start.sh /start.sh
CMD ["/start.sh"]
