#!/usr/bin/env bash

export $(grep -v '^#' .env | xargs)

# Server.cfg
sed -i 's|topLayerUri= com.tranzaxis.???|topLayerUri='$PKR_VAR_dist_uri'|g' for_users/server.cfg
sed -i 's|svnHomeUrl=$|svnHomeUrl=http://svn:18080/svn/'$PKR_VAR_repo_name'/dev/trunk|g' for_users/server.cfg
sed -i 's|#authUser=$|authUser='$PKR_VAR_svn_user'|g' for_users/server.cfg
sed -i 's|#authPassword=|authPassword='$PKR_VAR_svn_pass'|g' for_users/server.cfg
sed -i 's|#preloadThreads=|preloadThreads=3|g' for_users/server.cfg
sed -i 's|dbUrl=$|dbUrl=jdbc:oracle:thin:@db:1521/'$ORACLE_PDB'|g' for_users/server.cfg
sed -i 's|dbSchema=$|dbSchema=TEST|g' for_users/server.cfg
sed -i 's|user=$|user=TEST|g' for_users/server.cfg
sed -i 's|pwd=$|pwd='$ORACLE_PWD'|g' for_users/server.cfg
sed -i 's|instance =|instance=1|g' for_users/server.cfg
sed -i 's|#switchGuiOff|switchGuiOff|g' for_users/server.cfg

# Explorer.cfg
sed -i 's|topLayerUri= com.tranzaxis.???|topLayerUri='$PKR_VAR_dist_uri'|g' for_users/explorer/explorer.cfg
sed -i 's|svnHomeUrl=$|svnHomeUrl=http://localhost:18080/svn/'$PKR_VAR_repo_name'/dev/trunk|g' for_users/explorer/explorer.cfg
sed -i 's|#authUser=|authUser='$PKR_VAR_svn_user'|g' for_users/explorer/explorer.cfg
sed -i 's|#authPassword=|authPassword='$PKR_VAR_svn_pass'|g' for_users/explorer/explorer.cfg
sed -i 's|#localFileCacheDir=|localFileCacheDir=cache|g' for_users/explorer/explorer.cfg
sed -i 's|#downloadExplorer|downloadExplorer|g' for_users/explorer/explorer.cfg
sed -i 's|#preloadThreads=|preloadThreads=3|g' for_users/explorer/explorer.cfg

