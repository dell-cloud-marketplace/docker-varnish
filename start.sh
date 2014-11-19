#!/bin/bash

# File and folder variables.
VARNISH_FOLDER=/etc/varnish
DEFAULT_TEMPLATE=${VARNISH_FOLDER}/default.template
CONFIG_FOLDER=${VARNISH_FOLDER}/config
CONFIG_TEMPLATE=${CONFIG_FOLDER}/config.template
CONFIG_FILE=${CONFIG_FOLDER}/config.vcl

# If the config template is missing (either no volume or an empty volume was
# specified), copy the config template from the default.
if [ ! -f  $CONFIG_TEMPLATE ]; then
    echo -e "\e[32mUsing Default Template\e[39m"
    cp $DEFAULT_TEMPLATE $CONFIG_TEMPLATE
fi

# Patch any environmental variable references to create the config file.
envsubst < $CONFIG_TEMPLATE > $CONFIG_FILE

# The '-a' argument defines what address Varnish service HTTP requests from.
echo "Starting varnish"
varnishd -f $CONFIG_FILE -s malloc,$VARNISH_STORAGE_AMOUNT \
    -a 0.0.0.0:$VARNISH_PORT -p sess_timeout=$VARNISH_SESS_TIMEOUT

echo "Starting varnishlog"
varnishlog
