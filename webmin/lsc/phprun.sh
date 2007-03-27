#!/bin/bash
#
# Wrapper to make sure that (php) script won't run in CGI mode
#

unset SERVER_SOFTWARE
unset SERVER_NAME
unset GATEWAY_INTERFACE
unset REQUEST_METHOD
unset SCRIPT_FILENAME
unset QUERY_STRING

RUN=$1
shift

$RUN $@
      