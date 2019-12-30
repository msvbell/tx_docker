#!/bin/bash

# init svn repository
if [ ! -d "$REPOSITORY_DIR" ]; then
  /opt/csvn/bin/svnadmin create "$REPOSITORY_DIR"
  sed -i "s/# anon-access/anon-access/" "$REPOSITORY_DIR"/conf/svnserve.conf
  sed -i "s/# auth-access/auth-access/" "$REPOSITORY_DIR"/conf/svnserve.conf
  sed -i "s/# realm = My First Repository/realm = $SVN_USER/" "$REPOSITORY_DIR"/conf/svnserve.conf
  sed -i "s/# password-db = passwd/password-db = $SVN_PASSWORD/" "$REPOSITORY_DIR"/conf/svnserve.conf
fi

sed -i "s/Name=\"TEST\"/Name=\"$TEST_DB_NAME\"/" /tmp/repository.dumpfile
sed -i "s#jdbc:oracle:thin:@localhost:1521/TEST#jdbc:oracle:thin:@localhost:1521/$TEST_DB_NAME#" /tmp/repository.dumpfile
sed -i "s/Schema=\"TEST\"/Schema=\"$TEST_DB_NAME\"/" /tmp/repository.dumpfile
sed -i "s/Name=\"PROD\"/Name=\"$PROD_DB_NAME\"/" /tmp/repository.dumpfile
sed -i "s#jdbc:oracle:thin:@localhost:1521/PROD#jdbc:oracle:thin:@localhost:1521/$PROD_DB_NAME#" /tmp/repository.dumpfile
sed -i "s/Schema=\"PROD\"/Schema=\"$PROD_DB_NAME\"/" /tmp/repository.dumpfile

# import tranzaxis files to svn
# /opt/csvn/bin/svn import --username admin --password admin -m "Init" /tmp/repository_files/ http://localhost:18080/svn/TX
/opt/csvn/bin/svnadmin load $REPOSITORY_DIR < /tmp/repository.dumpfile

rm -rf /tmp/repository_files /tmp/repository.dumpfile

/config/bootstrap.sh