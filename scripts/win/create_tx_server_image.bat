@echo off

call %~dp0\common\info_echo.bat "Build TranzAxis server image"

packer build packer/tx-server

set img_desc=TranzAxis server
set str_fail=%img_desc% image build: FAIL
set str_success=%img_desc% image build: SUCCESS
IF NOT ERRORLEVEL 0 (
    call %~dp0\common\fail_echo.bat "%str_fail%"
    EXIT /B 1
) ELSE (
    call %~dp0\common\success_echo.bat "%str_success%"
    EXIT /B
)