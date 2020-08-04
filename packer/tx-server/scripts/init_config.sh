 #!/bin/sh

/bin/sed -i 's/docker_hostname/'"$HOSTNAME"'/g' /app/server/server.cfg

/app/server/server.sh