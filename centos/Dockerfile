# ownCloud, w/ Apache and PHP, using MySQL, Redis and APCu on CentOS 7
#
# VERSION 0.10

FROM       centos:7

LABEL maintainer "Mikael Karlsson <i8myshoes@gmail.com>"

# Perform updates
RUN yum -y update && yum clean all

# Install EPEL
RUN yum -y install epel-release && yum clean all

# Install IUS
RUN yum -y install https://centos7.iuscommunity.org/ius-release.rpm && yum clean all

# Install PHP 5.6
RUN yum -y install php56u php56u-mysqlnd php56u-pecl-apcu php56u-pecl-redis && yum clean all

# Install ownCloud 8.2 repo
ADD http://download.owncloud.org/download/repositories/8.2/CentOS_7/ce:8.2.repo /etc/yum.repos.d/

# Install ownCloud stable repo
# ADD http://download.owncloud.org/download/repositories/stable/CentOS_7/ce:stable.repo /etc/yum.repos.d/

# Install ownCloud and dependencies
RUN yum -y install owncloud-8.2* && yum clean all

# Install SSL module
RUN yum -y install mod_ssl && yum clean all

# Allow connections from everywhere
#RUN ln -s /etc/httpd/conf.d/owncloud-access.conf.avail /etc/httpd/conf.d/z-owncloud-access.conf

# Change ownership
RUN chown -R apache:apache /var/www/html/owncloud

# Configure ownCloud
RUN sed -r -i '/upload_max_filesize|post_max_size/ { s;\w*$;50G; }' /var/www/html/owncloud/.htaccess

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

# Enable HSTS
RUN sed -r -i '/<\/VirtualHost>/ i \  <IfModule mod_headers.c>\n\
    Header always set Strict-Transport-Security "max-age=15768000; includeSubDomains; preload"\n\
  </IfModule>' /etc/httpd/conf.d/ssl.conf

# Redirect / to /owncloud
# RUN sed -r -i '/\/VirtualHost/ i RedirectMatch "^/$" "/owncloud/"' /etc/httpd/conf.d/ssl.conf

# Change DocumentRoot
RUN sed -r -i '/^#?DocumentRoot/ { s/^#//; s;".*;"/var/www/html/owncloud"; }' /etc/httpd/conf.d/ssl.conf

# Silence Apache signature
RUN echo -e "\nServerSignature Off\nServerTokens Prod" >> /etc/httpd/conf/httpd.conf

# Silence PHP advertising
RUN sed -i '/^expose_php/ s/On/Off/' /etc/php.ini

# Rewrite requests to HTTPS
RUN echo -e "\nRewriteEngine On\n\
RewriteCond %{HTTPS} off\n\
RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI}" >> /etc/httpd/conf/httpd.conf

# Install Shibboleth repo
ADD http://download.opensuse.org/repositories/security://shibboleth/CentOS_7/security:shibboleth.repo /etc/yum.repos.d/

# Install Shibboleth
RUN yum -y install shibboleth && yum clean all

# Configure Shibboleth
RUN sed -r -i '/^#?<\/?Location/ { s/^#//; }' /etc/httpd/conf.d/ssl.conf
RUN sed -r -i '/<Location/ a\  AuthType shibboleth\n  Require shibboleth' /etc/httpd/conf.d/ssl.conf
RUN sed -r -i '49,$ s/^/#/' /etc/httpd/conf.d/shib.conf

# Expose volume points
VOLUME /srv/certs
VOLUME /var/www/html/owncloud/data

# Expose port 443
EXPOSE 443

# Get dumb-init
ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 /dumb-init
RUN chmod +x /dumb-init

# Set wrapper script as entrypoint
ADD ./wrapper.sh /wrapper.sh
STOPSIGNAL SIGWINCH
ENTRYPOINT ["/dumb-init", "-cv", "/wrapper.sh"]
CMD ["-D", "FOREGROUND"]
