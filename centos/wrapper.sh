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
  &

/usr/sbin/httpd -t
exec /usr/sbin/httpd "$@"
