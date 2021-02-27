@echo off

IF %1==cmd_load (
    echo One
EXIT /B
)

IF %1==cmd_build (
    echo Two
EXIT /B
)
