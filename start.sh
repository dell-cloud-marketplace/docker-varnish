#!/bin/bash

# Start varnish and log
varnishd -s malloc,${VARNISH_STORAGE_AMOUNT} -a 0.0.0.0:${VARNISH_PORT} -b ${VARNISH_BACKEND_IP}:${VARNISH_BACKEND_PORT}
varnishlog
