FROM ubuntu:trusty
MAINTAINER Dell Cloud Market Place <Cloud_Marketplace@dell.com>

# Update the package repository and install applications
RUN apt-get update -qq && \
  apt-get upgrade -yqq && \
  apt-get -yqq install varnish=3.0.5-2 && \
  apt-get -yqq clean

# The IP and PORT of the host to have cache acceleration
ENV VARNISH_BACKEND_IP 172.17.42.1
ENV VARNISH_BACKEND_PORT 80

# The size of the cache eg 100M = 100 Megabytes or 1G = 1 Gigabyte
ENV VARNISH_STORAGE_AMOUNT 100M

# The port varnish will listen on
ENV VARNISH_PORT 80

EXPOSE 80

ADD start.sh /start.sh
CMD ["/start.sh"]
