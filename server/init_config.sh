#!/bin/sh

EAS_IP=$(echo "$(sed -n '1p' /etc/hostname)")
sed -i 's/docker_hostname/'"$EAS_IP"'/g' /app/server.cfg
sed -i 's/instance_port/'"$INSTANCE_PORT"'/g' /app/server.cfg
sed -i 's/eas_port/'"$EAS_PORT"'/g' /app/server.cfg