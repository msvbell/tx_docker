@echo off

FOR /F "tokens=*" %%i in ('type .env') do SET %%i

echo "Building oracle databasee"
%LOCAL_PATH_TO_BASH% -c "packer/database/scripts/build_oracle_image.sh