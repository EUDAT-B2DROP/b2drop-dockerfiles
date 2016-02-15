#!/bin/bash
set -e

rm -rf /run/httpd/* /tmp/httpd*

/usr/sbin/httpd -t
exec /usr/sbin/httpd "$@"
