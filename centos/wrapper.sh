#!/bin/bash
set -e

rm -rf /run/httpd/* /tmp/httpd*

tail --follow --retry \
  /var/log/httpd/access_log \
  /var/log/httpd/error_log \
  /var/log/httpd/ssl_access_log \
  /var/log/httpd/ssl_error_log \
  /var/log/httpd/ssl_request_log \
  /var/www/html/owncloud/data/owncloud.log \
  /var/log/shibboleth/shibd.log \
  /var/log/shibboleth/shibd_warn.log \
  /var/log/shibboleth/signature.log \
  /var/log/shibboleth/transaction.log \
  /var/log/shibboleth-www/native.log \
  /var/log/shibboleth-www/native_warn.log \
  &

LD_LIBRARY_PATH=/opt/shibboleth/lib64 /usr/sbin/shibd -t
LD_LIBRARY_PATH=/opt/shibboleth/lib64 /usr/sbin/shibd -f

/usr/sbin/httpd -t
exec /usr/sbin/httpd "$@"
