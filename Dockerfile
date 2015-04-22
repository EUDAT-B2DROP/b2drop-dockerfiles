FROM       fedora:22
MAINTAINER Mikael Karlsson <i8myshoes@gmail.com>

# Perform updates
RUN dnf -y update && dnf clean all

RUN dnf install -y owncloud{,-httpd,-sqlite} && dnf clean all
# RUN dnf install -y owncloud{,-httpd,-postgresql} && dnf clean all
# RUN dnf install -y owncloud{,-nginx,-mysql} && dnf clean all

# Install SSL module and force SSL to be used by owncloud
RUN dnf install -y mod_ssl && dnf clean all
ADD ./forcessl.config.php /etc/owncloud/forcessl.config.php

# Allow connections from everywhere
RUN ln -s /etc/httpd/conf.d/owncloud-access.conf.avail /etc/httpd/conf.d/z-owncloud-access.conf

# Expose port 443 and set httpd as our entrypoint
EXPOSE 443
ENTRYPOINT ["/usr/sbin/httpd"]
CMD ["-D", "FOREGROUND"]
