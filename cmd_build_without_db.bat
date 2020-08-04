@echo off
echo %TIME%

SET docker_network_name=tx
FOR /F "tokens=*" %%i in ('type .env') do SET %%i

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
	DISABLE_UPGRADE_DB
    QUESTION_YES_ALL
EXIT /B
