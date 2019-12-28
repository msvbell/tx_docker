#!/bin/bash

if [ ! -d "$REPOSITORY_DIR" ]; then
  /opt/csvn/bin/svnadmin create "$REPOSITORY_DIR"
#  echo "$SVN_USER = $SVN_PASSWORD" >> "$REPOSITORY_DIR"/conf/passwd
  sed -i "s/# anon-access/anon-access/" "$REPOSITORY_DIR"/conf/svnserve.conf
  sed -i "s/# auth-access/auth-access/" "$REPOSITORY_DIR"/conf/svnserve.conf
  sed -i "s/# realm = My First Repository/realm = $SVN_USER/" "$REPOSITORY_DIR"/conf/svnserve.conf
  sed -i "s/# password-db = passwd/password-db = $SVN_PASSWORD/" "$REPOSITORY_DIR"/conf/svnserve.conf

fi

echo "Hello there!"
/config/bootstrap.sh
echo "Hello there too!"
