@echo off
echo %TIME%

SET docker_network_name=tx
FOR /F "tokens=*" %%i in ('type .env') do SET %%i

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
