#!/bin/bash

#sed -i "s/MaxPermSize=128m/MaxPermSize=2048m/" /opt/csvn/data-initial/conf/csvn-wrapper.conf
#sed -i "s/initmemory=64/initmemory=512/" /opt/csvn/data-initial/conf/csvn-wrapper.conf
#sed -i "s/maxmemory=512/maxmemory=1024/" /opt/csvn/data-initial/conf/csvn-wrapper.conf

cp -r /opt/csvn/data-initial/* /opt/csvn/data

/opt/csvn/bin/htpasswd -bB /opt/csvn/data/conf/svn_auth_file $SVN_USER $SVN_PASSWORD

/config/bootstrap.sh