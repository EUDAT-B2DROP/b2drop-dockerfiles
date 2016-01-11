# ownCloud, w/ Apache, using MySQL on CentOS 7
#
# VERSION 0.7

FROM       centos:7
MAINTAINER Mikael Karlsson <i8myshoes@gmail.com>

# Perform updates
RUN yum -y update && yum clean all

# Install EPEL
RUN yum -y install epel-release && yum clean all

# Install ownCloud 8.1 repo
ADD http://download.opensuse.org/repositories/isv:ownCloud:community:8.1/CentOS_7/isv:ownCloud:community:8.1.repo /etc/yum.repos.d/

# Install ownCloud and dependencies
RUN yum -y install owncloud php-mysql && yum clean all

# Install SSL module
RUN yum -y install mod_ssl && yum clean all

# Allow connections from everywhere
#RUN ln -s /etc/httpd/conf.d/owncloud-access.conf.avail /etc/httpd/conf.d/z-owncloud-access.conf

# Change ownership
RUN chown -R apache:apache /var/www/html/owncloud

# Configure Apache
RUN echo "<h1>Oops!</h1>" > /var/www/html/index.html

# Change certificate paths
RUN sed -r -i \
        -e '/^#?SSLCertificateFile/ { s/^#//; s;/.*;/srv/certs/server.crt; }' \
        -e '/^#?SSLCertificateKeyFile/ { s/^#//; s;/.*;/srv/certs/server.key; }' \
        -e '/^#?SSLCertificateChainFile/ { s/^#//; s;/.*;/srv/certs/server_ca.crt; }' /etc/httpd/conf.d/ssl.conf

# Disable SSLv3
RUN sed -r -i '/^#?SSLProtocol/ { s/^#//; s/$/ -SSLv3/; }' /etc/httpd/conf.d/ssl.conf

# Disable RC4
RUN sed -r -i '/^SSLCipherSuite/ { s/$/:!RC4/; }' /etc/httpd/conf.d/ssl.conf

# Disable TRACE
RUN echo -e "\nTraceEnable off" >> /etc/httpd/conf.d/ssl.conf

# Redirect / to /owncloud
# RUN sed -r -i '/\/VirtualHost/ i RedirectMatch "^/$" "/owncloud/"' /etc/httpd/conf.d/ssl.conf

# Change DocumentRoot
RUN sed -r -i '/^#?DocumentRoot/ { s/^#//; s;".*;"/var/www/html/owncloud"; }' /etc/httpd/conf.d/ssl.conf

# Rewrite requests to HTTPS
RUN echo -e "\nRewriteEngine On\n\
RewriteCond %{HTTPS} off\n\
RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI}" >> /etc/httpd/conf/httpd.conf

# Expose volume points
VOLUME /srv/certs
VOLUME /var/www/html/owncloud/data

# Expose port 443
EXPOSE 443

# Set wrapper script as entrypoint
ADD ./wrapper.sh /wrapper.sh
ENTRYPOINT ["/wrapper.sh"]
CMD ["-D", "FOREGROUND"]
