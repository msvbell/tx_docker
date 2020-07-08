 #!/bin/sh

EAS_IP=$(echo "$(sed -n '1p' /etc/hostname)")
sed -i 's/docker_hostname/'"$EAS_IP"'/g' /app/server/server.cfg
sed -i 's/instance_port/'"$INSTANCE_PORT"'/g' /app/server/server.cfg
sed -i 's/eas_port/'"$EAS_PORT"'/g' /app/server/server.cfg

# Project init process
sed -i 's|http://localhost:18080/svn/TX|http://localhost:'"$SVN_PORT"'/svn/TX|'