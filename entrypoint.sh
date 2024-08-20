#!/bin/bash

vbox_socket="/opt/vbox/vbox.sock"
if [ ! -e $vbox_socket ]; then
    echo "vbox.sock not found"
    exit 1
else 
    sudo chown cape $vbox_socket
fi

cwd="/opt/CAPEv2"
if [ ! -d $cwd ]; then
    echo "CAPEv2 not found"
    exit 1
else 
    sudo chown -R cape $cwd
fi

cd $cwd
sudo -u cape python cuckoo.py
