@echo off
:: СКРИПТ НЕДОДЕЛАН!!!
:: TODO

::set version=3-3.2.17.10.17
::set version=4-3.2.17.10.21
::set version=5-3.2.17.10.22
::set version=6-3.2.17.10.25
::set version=7-3.2.17.10.25v1
set version=8-3.2.17.10.25v2
set suffix="(7-3.2.17.10.25v1)"
set product=com.tranzaxis.banxelv
set distr_file="%product%-%version% %suffix%.zip"
set svn_pass="Password123"

::CALL :UPDATE_MANAGER
:: Start last containers
::CALL :START_CONTAINERS
:: Run manager to update
::CALL :RUN_MANAGER_TO_UPDATE
:: Commit changes
::CALL :COMMIT_CONTAINERS
::CALL :START_TX_CONTAINER
::
CALL :MANAGER_RUN_BUILD
::
EXIT /B


:START_CONTAINERS
    :: | Starts latest containers
    :: | Use:
    :: | CALL :start_containers
    CALL :START_DB_CONTAINER
    CALL :START_SVN_CONTAINER
    CALL :START_TX_CONTAINER
    echo "Wait for db..."
    CALL :WAIT_FOR_DB
    echo "All containers are running"
EXIT /B

:RUN_MANAGER_TO_UPDATE
    CALL :MANAGER_RUN_LOAD_UPDATES
    CALL :MANAGER_RUN_BUILD
EXIT /B

:UPDATE_MANAGER
    :: Update manager in container
    docker run ^
    --name tmp_manager ^
    -v %cd%/tranzaxis/manager/build.manager.conf:/data/manager/manager.conf ^
    -v %cd%/distribs:/data/project/upgrades:ro ^
    --net=tx ^
    --network-alias=manager ^
    -ti local/tx-manager:latest ^
    CMD_UPDATE_MANAGER_FROM_ARCHIVE ^
    UPGRADE_FILE_PATH=/data/project/upgrades/%distr_file% ^
    QUESTION_YES_ALL

    :: Get manager version
    for /f %%i in ('docker exec tmp_manager CMD_VERSION') do set manager_version=%%i

    docker stop tmp_manager
    docker commit tmp_manager local/tx-manager:%manager_version%
EXIT /B

:MANAGER_RUN_LOAD_UPDATES
    docker run --rm ^
    -v %cd%/tranzaxis/manager/build.manager.conf:/data/manager/manager.conf ^
    -v %cd%/distribs:/data/project/upgrades:ro ^
    --net=tx ^
    --network-alias=manager ^
    -ti local/tx-manager:latest ^
    CMD_LOAD_UPDATES ^
    PROJECT_DIR=/data/project ^
    SVN_PWD=%svn_pass% ^
    LOAD_UPDATE_ALL_FILES ^
    QUESTION_YES_ALL
EXIT /B

:MANAGER_RUN_BUILD
    docker run --rm ^
    -v %cd%/tranzaxis/manager/build.manager.conf:/data/manager/manager.conf ^
    -v %cd%/distribs:/data/project/upgrades:ro ^
    --net=tx ^
    --network-alias=manager ^
    -ti local/tx-manager:latest ^
    CMD_BUILD ^
    CONFIG_FILE=/data/manager/manager.conf ^
    DATABASE_DRIVER_PATH=/data/ojdbc8.jar ^
    USE_PRODUCT=%product% ^
    USE_DISTRIBUTION_KIT="%version%" ^
    QUESTION_YES_ALL
EXIT /B

:COMMIT_CONTAINERS
    docker stop tx_server
    docker stop svn
    docker stop db

    docker commit tx_server local/tx-server:%version%
    docker commit svn local/tx-svn:%version%
    docker commit db local/tx-db-oracle:12.2.0.1-%version%
EXIT /B

:START_TX_CONTAINER
    docker run -d ^
    --name tx_server ^
    -p 10200:10200 ^
    -p 10201:10201 ^
    --hostname=txs ^
    --net=tx ^
    --network-alias=tx-server ^
    local/tx-server:latest
EXIT /B

:START_SVN_CONTAINER
    docker run -d ^
    --name svn ^
    -p 18080:18080 ^
    --net=tx ^
    --network-alias=svn ^
    local/tx-svn:latest
EXIT /B

:START_DB_CONTAINER
    docker run -d --name db ^
    --net=tx ^
    --network-alias=db ^
    local/tx-db-oracle:latest
EXIT /B

:WAIT_FOR_DB
timeout 10 > NUL
FOR /F %%I IN ('docker logs db ^| %SystemRoot%\System32\find.exe /I /C "DATABASE IS READY TO USE"') DO SET "_count=%%I"
IF %_count%==0 (
    goto :WAIT_FOR_DB
) ELSE (
    echo "DATABASE IS READY"
)


:: TODO
:: =========================
::          TESTS
:: ========================

:test_tx_container
    CALL :START_TX_CONTAINER
    docker ps --filter name=tx_server --format "{{.Names}} is {{.State}}"
EXIT /B

:test_svn
    CALL :START_SVN_CONTAINER
    docker ps --filter name=svn --format "{{.Names}} is {{.State}}"
EXIT /B