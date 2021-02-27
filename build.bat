@echo off
echo %TIME%
echo. > build.log
echo 1

SET docker_network_name=tx
FOR /F "tokens=*" %%i in ('type .env') do SET %%i

echo 2

mkdir for_users\explorer 2> NUL
mkdir for_users\images  2> NUL

docker network create %docker_network_name% > NUL

echo 3
set "fff=%1"
IF NOT DEFINED fff goto :all

IF %1==cmd_load (
    call scripts\win\run_cmd_load_updates.bat %docker_network_name% > CON
EXIT /B
)

echo 4

IF %1==cmd_build (
    call scripts\win\run_cmd_build.bat  %docker_network_name% > CON
EXIT /B
)

echo a

IF %1==step_1 (
    call scripts\win\create_svn_base_image.bat > CON
    if %errorlevel% neq 0 exit /b %errorlevel%

    call :start_svn_container
    if %errorlevel% neq 0 exit /b %errorlevel%

    echo Timeout 30 sec
    timeout 30 > NUL

    call scripts\win\create_tx_manager_image.bat > CON
    if %errorlevel% neq 0 exit /b %errorlevel%
EXIT /B
)

echo b

IF %1==step_2 (
    call scripts\win\run_cmd_load_updates.bat %docker_network_name% > CON
    if %errorlevel% neq 0 exit /b %errorlevel%


    call scripts\win\create_file_tablespace.bat > CON
    if %errorlevel% neq 0 exit /b %errorlevel%


EXIT /B
)

echo c

IF %1==step_3 (
    CALL :start_db_container


    echo Waiting for db when it ready... about 20-30 min
    CALL :check

CALL scripts\win\create_tx_server_image.bat
if %errorlevel% neq 0 exit /b %errorlevel%

call scripts\win\run_cmd_build.bat  %docker_network_name% > CON
if %errorlevel% neq 0 exit /b %errorlevel%

docker exec svn yes | cp -r /opt/csvn/data/* /opt/csvn/data-initial
if %errorlevel% neq 0 exit /b %errorlevel%

CALL :edit_configs
if %errorlevel% neq 0 exit /b %errorlevel%
EXIT /B
)

echo d

IF %1==step_4 (
CALL :start_tx_server_container
if %errorlevel% neq 0 exit /b %errorlevel%


echo Wait for tx server
timeout 180 > NUL


call :export_containers
if %errorlevel% neq 0 exit /b %errorlevel%
EXIT /B
)

echo e

IF %1==step_5 (
call :create_docker_compose_file
if %errorlevel% neq 0 exit /b %errorlevel%

call :create_import_file_for_users
if %errorlevel% neq 0 exit /b %errorlevel%

call :create_hostname_sql
if %errorlevel% neq 0 exit /b %errorlevel%

call :clear
if %errorlevel% neq 0 exit /b %errorlevel%

rm -r temp images
rm db/install/tablespaces.sql
EXIT /B
)

IF %1==clear (
call :clear
if %errorlevel% neq 0 exit /b %errorlevel%
EXIT /B
)

:all

echo f

call scripts\win\create_svn_base_image.bat > CON
if %errorlevel% neq 0 exit /b %errorlevel%

call :start_svn_container
if %errorlevel% neq 0 exit /b %errorlevel%

echo Timeout 30 sec
timeout 30 > NUL

call scripts\win\create_tx_manager_image.bat > CON
if %errorlevel% neq 0 exit /b %errorlevel%


call scripts\win\run_cmd_load_updates.bat %docker_network_name% > CON
if %errorlevel% neq 0 exit /b %errorlevel%


call scripts\win\create_file_tablespace.bat > CON
if %errorlevel% neq 0 exit /b %errorlevel%

CALL :start_db_container


echo Waiting for db when it ready... about 20-30 min
CALL :check


CALL scripts\win\create_tx_server_image.bat
if %errorlevel% neq 0 exit /b %errorlevel%

call scripts\win\run_cmd_build.bat  %docker_network_name% > CON
if %errorlevel% neq 0 exit /b %errorlevel%

docker exec svn yes | cp -r /opt/csvn/data/* /opt/csvn/data-initial
if %errorlevel% neq 0 exit /b %errorlevel%

CALL :edit_configs
if %errorlevel% neq 0 exit /b %errorlevel%

CALL :start_tx_server_container
if %errorlevel% neq 0 exit /b %errorlevel%


echo Wait for tx server
timeout 180 > NUL


call :export_containers
if %errorlevel% neq 0 exit /b %errorlevel%

call :create_docker_compose_file
if %errorlevel% neq 0 exit /b %errorlevel%

call :create_import_file_for_users
if %errorlevel% neq 0 exit /b %errorlevel%

call :create_hostname_sql
if %errorlevel% neq 0 exit /b %errorlevel%

call :clear
if %errorlevel% neq 0 exit /b %errorlevel%

rm -r temp images
rm db/install/tablespaces.sql

echo %TIME%
EXIT /B %ERRORLEVEL%


:clear
    echo Cleanup
    docker container rm --force --volumes db > build.log 2> NUL
    docker container rm --force tx_server > build.log 2> NUL
    docker container rm --force svn  2> NUL
    docker network rm %docker_network_name%  2> NUL
EXIT /B %ERRORLEVEL%


:start_svn_container
    docker run -d ^
    --name svn ^
    -p 18080:18080 ^
    -p 3343:3343 ^
    -p 4434:4434 ^
    --net=%docker_network_name% ^
    --network-alias=svn ^
    local/tx-svn-base
EXIT /B %ERRORLEVEL%


:start_db_container
    echo Start start_db_container
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
EXIT /B %ERRORLEVEL%


:check
    timeout 10 > NUL
    FOR /F %%I IN ('docker logs db ^| %SystemRoot%\System32\find.exe /I /C "DATABASE IS READY TO USE"') DO SET "_count=%%I"
    IF %_count%==0 (
        goto :check
    ) ELSE (
        echo "DATABASE READY"
    )
EXIT /B %ERRORLEVEL%


:edit_configs
    echo Start edit_configs
    "%LOCAL_PATH_TO_BASH%" edit_configs.sh
EXIT /B %ERRORLEVEL%


:start_tx_server_container
    echo Start tx server container
    docker run -d ^
    --name tx_server ^
    -v %cd%/for_users/server.cfg:/app/server/server.cfg ^
    -p 10200:10200 ^
    -p 10201:10201 ^
    --hostname=txs ^
    --net=tx --network-alias=tx-server ^
    local/tx-server  

    
EXIT /B %ERRORLEVEL%


:export_containers
    echo Export containers
    docker container commit tx_server local/tx-server:%VERSION_TAG%  
    docker container commit svn local/tx-svn:%VERSION_TAG%  
    docker container commit db local/tx-db-oracle:12.2.0.1-%VERSION_TAG%  

    docker tag local/tx-server:%VERSION_TAG% local/tx-server:latest  
    docker tag local/tx-svn:%VERSION_TAG% local/tx-svn:latest  
    docker tag local/tx-db-oracle:12.2.0.1-%VERSION_TAG% local/tx-db-oracle:12.2.0.1-latest  

    docker image save --output="for_users/images/tx_server.%VERSION_TAG%.tar" local/tx-server:%VERSION_TAG%  
    docker image save --output="for_users/images/svn.%VERSION_TAG%.tar" local/tx-svn:%VERSION_TAG%  
    docker image save --output="for_users/images/db.%VERSION_TAG%.tar" local/tx-db-oracle:12.2.0.1-%VERSION_TAG%  
EXIT /B %ERRORLEVEL%


:create_docker_compose_file
echo Create docker compose file
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

    
EXIT /B %ERRORLEVEL%


:create_hostname_sql
echo Create hostname sql
(
echo ALTER SESSION SET container=RBS;
echo UPDATE TEST.RDX_SAP t
echo SET t.ADDRESS = 'tx_server:10001'
echo WHERE t.ID = 2;
) > "for_users/hostname.sql"
EXIT /B %ERRORLEVEL%


:create_import_file_for_users
echo Create import file for users
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
    
EXIT /B %ERRORLEVEL%