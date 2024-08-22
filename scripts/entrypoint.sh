#!/bin/bash

vbox_socket="/opt/vbox/vbox.sock"
if [ ! -e $vbox_socket ]; then
    echo "vbox.sock not found"
    exit 1
else 
    sudo chown cape $vbox_socket
fi

if [ -z "$(sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='cape'")" ]; then
    sudo -u postgres psql -c "CREATE ROLE cape WITH SUPERUSER LOGIN PASSWORD 'SuperPuperSecret';"
fi

if [ -z "$(sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -w cape)" ]; then
    sudo -u postgres psql -c "CREATE DATABASE cape WITH OWNER cape;"
fi

work=/work
if [ ! -d $work ]; then
    echo "Work directory not found"
    exit 1
else 
    sudo chown -R cape $work
fi

cwd="/opt/CAPEv2"
if [ ! -d $cwd ]; then
    echo "CAPEv2 not found"
    exit 1
fi 

if [ -L $cwd/conf ]; then
    echo "CAPEv2 configuration is a symbolic link"
elif [ -d $work/conf ]; then
    echo "CAPEv2 configuration backup found"
    rm -rf $cwd/conf
    chown -R cape $work/conf
    ln -s $work/conf $cwd/conf
elif [ -d $cwd/conf ]; then
    echo "CAPEv2 configuration found"
    mv $cwd/conf $work
    ln -s $work/conf $cwd/conf
fi

if [ -L $cwd/storage ]; then
    echo "CAPEv2 storage is a symbolic link"
elif [ -d $work/storage ]; then
    echo "CAPEv2 storage backup found"
    rm -rf $cwd/storage
    chown -R cape $work/storage
    ln -s $work/storage $cwd/storage
elif [ -d $cwd/storage ]; then
    echo "CAPEv2 storage found"
    mv $cwd/storage $work
    ln -s $work/storage $cwd/storage
else
    echo "CAPEv2 storage not found"
    sudo -u cape mkdir -p $work/storage
    ln -s $work/storage $cwd/storage
fi

if [ -L $cwd/log ]; then
    echo "CAPEv2 log is a symbolic link"
elif [ -d $work/log ]; then
    echo "CAPEv2 log backup found"
    rm -rf $cwd/log
    chown -R cape $work/log
    ln -s $work/log $cwd/log
elif [ -d $cwd/log ]; then
    echo "CAPEv2 log found"
    mv $cwd/log $work
    ln -s $work/log $cwd/log
else
    echo "CAPEv2 log not found"
    sudo -u cape mkdir -p $work/log
    ln -s $work/log $cwd/log
fi

if ! systemctl is-active --quiet cape-rooter.service; then
    echo "Starting cape-rooter.service"
    systemctl restart cape-rooter.service
fi

if ! systemctl is-active --quiet cape.service; then
    echo "Starting cape.service"
    systemctl restart cape.service
fi

if ! systemctl is-active --quiet cape-web.service; then
    echo "Starting cape-web.service"
    systemctl restart cape-web.service
fi

if ! systemctl is-active --quiet cape-processor.service; then
    echo "Starting cape-processor.service"
    systemctl restart cape-processor.service
fi

echo "End of entrypoint"
