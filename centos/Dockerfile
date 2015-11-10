FROM       centos:7
MAINTAINER Mikael Karlsson <i8myshoes@gmail.com>

# Perform updates
RUN yum -y update && yum clean all

# Install EPEL
RUN yum -y install epel-release && yum clean all

# Install ownCloud repo
ADD http://download.opensuse.org/repositories/isv:ownCloud:community/CentOS_7/isv:ownCloud:community.repo /etc/yum.repos.d/

# Install ownCloud and dependencies
RUN yum -y install owncloud php-mysql && yum clean all

# Install SSL module and force SSL to be used by owncloud
RUN yum -y install mod_ssl && yum clean all
ADD ./forcessl.config.php /var/www/html/owncloud/config/forcessl.config.php

# Allow connections from everywhere
#RUN ln -s /etc/httpd/conf.d/owncloud-access.conf.avail /etc/httpd/conf.d/z-owncloud-access.conf

# Add EUDAT specific configurations
ADD ./eudat.config.php /var/www/html/owncloud/config/eudat.config.php

# Change ownership
RUN chown -R apache:apache /var/www/html/owncloud

# Configure Apache
RUN echo "<h1>Oops!</h1>" > /var/www/html/index.html

# Change certificate paths
RUN sed -r -i \
        -e '/^#?SSLCertificateFile/ { s/^#//; s;/.*;/srv/certs/server.crt; }' \
        -e '/^#?SSLCertificateKeyFile/ { s/^#//; s;/.*;/srv/certs/server.key; }' \
        -e '/^#?SSLCertificateChainFile/ { s/^#//; s;/.*;/srv/certs/server_ca.crt; }' /etc/httpd/conf.d/ssl.conf

# Redirect / to /owncloud
# RUN sed -r -i '/\/VirtualHost/ i RedirectMatch "^/$" "/owncloud/"' /etc/httpd/conf.d/ssl.conf

# Change DocumentRoot
RUN sed -r -i '/^#?DocumentRoot/ { s/^#//; s;".*;"/var/www/html/owncloud"; }' /etc/httpd/conf.d/ssl.conf

# Rewrite requests to HTTPS
RUN echo -e "\nRewriteEngine On\n\
RewriteCond %{HTTPS} off\n\
RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI}" >> /etc/httpd/conf/httpd.conf

# Expose volume points
VOLUME /var/www/html/owncloud/data
VOLUME /srv/certs

# Expose port 443 and set httpd as our entrypoint
EXPOSE 443
ENTRYPOINT ["/usr/sbin/httpd"]
CMD ["-D", "FOREGROUND"]
