#!/bin/bash
set -e

rm -rf /run/httpd/* /tmp/httpd*

exec /usr/sbin/httpd "$@"
