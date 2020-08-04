@echo off
echo %TIME%

SET docker_network_name=tx
FOR /F "tokens=*" %%i in ('type .env') do SET %%i

mkdir for_users\explorer 2> NUL
mkdir for_users\images  2> NUL

docker network create %docker_network_name%  1> NUL


CALL :build_svn_base_image
CALL :build_tx_manager_image
CALL :start_svn_container
CALL :run_CMD_LOAD_UPDATES
CALL :create_tablespace_file
CALL :start_db_container
echo Waiting for db when it ready... about 20-30 min
CALL :check

CALL :build_tx_server_base_image
CALL :run_CMD_BUILD
CALL :edit_configs
CALL :start_tx_server_container

echo Wait for tx server
timeout 180 > NUL

CALL :export_containers
CALL :create_docker_compose_file
CALL :create_import_file_for_users
CALL :create_hostname_sql
CALL :clear

rm -r temp images
rm db/install/tablespaces.sql

echo %TIME%
EXIT /B


:clear
    docker container rm --force --volumes db 2> NUL
    docker container rm --force tx_server 2> NUL
    docker container rm --force svn 2> NUL
    docker network rm %docker_network_name% 2> NUL
EXIT /B


:build_svn_base_image
    packer build packer/svn
    timeout 10 > NUL
EXIT /B


:build_tx_manager_image
    packer build packer/tx-manager
    timeout 10 > NUL
EXIT /B


:start_svn_container
    docker run -d ^
    --name svn ^
    -p 18080:18080 ^
    -p 3343:3343 ^
    -p 4434:4434 ^
    --net=%docker_network_name% ^
    --network-alias=svn ^
    local/tx-svn-base
    :: wait for svn startup
    timeout 30 > NUL
EXIT /B


:build_tx_server_base_image
    packer build packer/tx-server
EXIT /B


:run_CMD_LOAD_UPDATES
    docker run --rm ^
    -v %cd%/config/manager/build.manager.conf:/data/manager/manager.conf ^
    -v %cd%/distribs:/data/project/upgrades:ro ^
    --net=%docker_network_name% ^
    --network-alias=manager ^
    -ti local/tx-manager ^
    CMD_LOAD_UPDATES ^
    CONFIG_FILE=/data/manager/manager.conf ^
    LOAD_UPDATE_ALL_FILES ^
    QUESTION_YES_ALL

    timeout 5 > NUL
EXIT /B


:create_tablespace_file
    docker run --rm ^
    -v %cd%/db/install/tablespaces.sql:/tmp/tablespaces.sql ^
    --entrypoint=/bin/bash ^
    -ti local/tx-manager -c "/bin/cp /tmp/tablespaces.sql /tmp/tablespaces_tmp.sql && /bin/sed -i 's|&&DIR|/opt/oracle/oradata/TX/%ORACLE_PDB%|g' /tmp/tablespaces_tmp.sql && /bin/cat /tmp/tablespaces_tmp.sql > /tmp/tablespaces.sql"

    echo alter session set container=%ORACLE_PDB%%; > db\install\01_tablespaces.sql
    more +1 db\install\tablespaces.sql >> db\install\01_tablespaces.sql
    rm db\install\tablespaces.sql
EXIT /B


:start_db_container
    docker run -d --name db ^
    -v %cd%/db/install/00_prepare.sql:/opt/oracle/scripts/setup/01.sql ^
    -v %cd%/db/install/01_tablespaces.sql:/opt/oracle/scripts/setup/02.sql ^
    -p 6622:1521 ^
    --env ORACLE_SID=%ORACLE_SID% ^
    --env ORACLE_PWD=%ORACLE_PWD% ^
    --env ORACLE_PDB=%ORACLE_PDB% ^
    --net=%docker_network_name% ^
    --network-alias=db ^
    oracle/database:12.2.0.1-ee
EXIT /B


:check
    timeout 10 > NUL
    FOR /F %%I IN ('docker logs db ^| %SystemRoot%\System32\find.exe /I /C "DATABASE IS READY TO USE"') DO SET "_count=%%I"
    IF %_count%==0 (
        goto :check
    ) ELSE (
        echo "DATABASE READY"
    )
EXIT /B


:run_CMD_BUILD
    docker run --rm ^
    -v %cd%/config/manager/build.manager.conf:/data/manager/manager.conf ^
    -v %cd%/distribs:/data/project/upgrades:ro ^
    --net=%docker_network_name% ^
    --network-alias=manager ^
    -ti local/tx-manager ^
    CMD_BUILD ^
    CONFIG_FILE=/data/manager/manager.conf ^
    DATABASE_DRIVER_PATH=/data/ojdbc8.jar ^
    QUESTION_YES_ALL
EXIT /B


:edit_configs
    "%LOCAL_PATH_TO_BASH%" edit_configs.sh
EXIT /B


:start_tx_server_container
    docker run -d ^
    --name tx_server ^
    -v %cd%/for_users/server.cfg:/app/server/server.cfg ^
    -p 10200:10200 ^
    -p 10201:10201 ^
    --hostname=txs ^
    --net=tx --network-alias=tx-server ^
    local/tx-server
EXIT /B


:export_containers
    docker container commit tx_server local/tx-server:%VERSION_TAG%
    docker container commit svn local/tx-svn:%VERSION_TAG%
    docker container commit db local/tx-db-oracle:12.2.0.1-%VERSION_TAG%

    docker tag local/tx-server:%VERSION_TAG% local/tx-server:latest
    docker tag local/tx-svn:%VERSION_TAG% local/tx-svn:latest
    docker tag local/tx-db-oracle:12.2.0.1-%VERSION_TAG% local/tx-db-oracle:12.2.0.1-latest

    docker image save --output="for_users/images/tx_server.%VERSION_TAG%.tar" local/tx-server:%VERSION_TAG%
    docker image save --output="for_users/images/svn.%VERSION_TAG%.tar" local/tx-svn:%VERSION_TAG%
    docker image save --output="for_users/images/db.%VERSION_TAG%.tar" local/tx-db-oracle:12.2.0.1-%VERSION_TAG%
EXIT /B


:create_docker_compose_file
(
echo version: '3'
echo.
echo services:
echo.
echo   tx:
echo     image: local/tx-server:%VERSION_TAG%
echo     hostname: tx_server
echo     environment:
echo       TZ: Europe/Moscow
echo     depends_on:
echo       - db
echo       - svn
echo     ports:
echo       - "10001:10001"
echo.
echo   db:
echo     image: local/tx-db-oracle:12.2.0.1-%VERSION_TAG%
echo     environment:
echo       TZ: Europe/Moscow
echo     volumes:
echo     - "./hostname.sql:/opt/oracle/scripts/startup/01.sql"
echo     - "dbdata:/opt/oracle/oradata"
echo     ports:
echo       - "1521:1521"
echo.
echo   svn:
echo     image: local/tx-svn:%VERSION_TAG%
echo     environment:
echo       TZ: Europe/Moscow
echo     volumes:
echo     - "svndata:/opt/csvn/data/repositories"
echo     ports:
echo       - "18080:18080"
echo       - "3343:3343"
echo       - "4434:4434"
echo.
echo volumes:
echo   dbdata:
echo   svndata:
) > "for_users/docker-compose.yaml"
EXIT /B


:create_hostname_sql
(
echo ALTER SESSION SET container=RBS;
echo UPDATE TEST.RDX_SAP t
echo SET t.ADDRESS = 'tx_server:10001'
echo WHERE t.ID = 2;
) > "for_users/hostname.sql"
EXIT /B


:create_import_file_for_users
(
echo #!/usr/bin/env bash
echo docker load -i images/svn.%VERSION_TAG%.tar
echo docker load -i images/tx_server.%VERSION_TAG%.tar
echo docker load -i images/db.%VERSION_TAG%.tar
) > "for_users/import.sh"

(
echo @echo off
echo docker load -i images/svn.%VERSION_TAG%.tar
echo docker load -i images/tx_server.%VERSION_TAG%.tar
echo docker load -i images/db.%VERSION_TAG%.tar
) > "for_users/import.bat"

bin\dos2unix.exe for_users/import.sh
bin\dos2unix.exe for_users/explorer/explorer.sh
bin\dos2unix.exe for_users/explorer/explorer_mac.sh
EXIT /B