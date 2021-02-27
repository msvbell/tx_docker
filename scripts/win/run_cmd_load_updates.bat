@echo off

call %~dp0\common\info_echo.bat "Start cmd_load_updates"

docker run --rm ^
-v %cd%/config/manager/build.manager.conf:/data/manager/manager.conf ^
-v %cd%/distribs:/data/project/upgrades:ro ^
--net=tx ^
--network-alias=manager ^
-ti local/tx-manager ^
CMD_LOAD_UPDATES ^
CONFIG_FILE=/data/manager/manager.conf ^
LOAD_UPDATE_ALL_FILES ^
QUESTION_YES_ALL


set img_desc=Run CMD_LOAD_UPDATES
set str_fail=%img_desc%: FAIL
set str_success=%img_desc%: SUCCESS

IF %errorlevel% neq 0 (
    call %~dp0\common\fail_echo.bat "%str_fail%"
    EXIT /B 1
) ELSE (
    call %~dp0\common\success_echo.bat "%str_success%"
    EXIT /B
)