@echo off

call %~dp0\common\info_echo.bat "Start create_table_space"

echo %cd%

docker run --rm ^
-v %cd%/db/install/tablespaces.sql:/tmp/tablespaces.sql ^
--entrypoint=/bin/bash ^
-ti local/tx-manager -c "/bin/cp /tmp/tablespaces.sql /tmp/tablespaces_tmp.sql && /bin/sed -i 's|&&DIR|/opt/oracle/oradata/TX/%ORACLE_PDB%|g' /tmp/tablespaces_tmp.sql && /bin/cat /tmp/tablespaces_tmp.sql > /tmp/tablespaces.sql"

echo alter session set container=%ORACLE_PDB%; > %cd%\db\install\01_tablespaces.sql
more +1 %cd%\db\install\tablespaces.sql >> %cd%\db\install\01_tablespaces.sql
rm %cd%\db\install\tablespaces.sql

set img_desc=Create tablespace.sql file
set str_fail=%img_desc%: FAIL
set str_success=%img_desc%: SUCCESS
IF NOT ERRORLEVEL 0 (
    call %~dp0\common\fail_echo.bat "%str_fail%"
    EXIT /B 1
) ELSE (
    call %~dp0\common\success_echo.bat "%str_success%"
    EXIT /B
)