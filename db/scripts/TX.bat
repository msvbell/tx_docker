mkdir C:\app\sivanov\virtual
if %ERRORLEVEL% == 0 ( C:\app\sivanov\virtual\product\12.2.0\dbhome_1\bin\oradim.exe -ACL -setperm diag -USER ORA_OraDB12Home1_SVCACCTS -OBJTYPE dir -OBJPATH C:\app\sivanov\virtual -RECURSE false ) 
mkdir C:\app\sivanov\virtual\admin\TX\adump
if %ERRORLEVEL% == 0 ( C:\app\sivanov\virtual\product\12.2.0\dbhome_1\bin\oradim.exe -ACL -setperm diag -USER ORA_OraDB12Home1_SVCACCTS -OBJTYPE dir -OBJPATH C:\app\sivanov\virtual\admin\TX\adump -RECURSE false ) 
mkdir C:\app\sivanov\virtual\admin\TX\dpdump
if %ERRORLEVEL% == 0 ( C:\app\sivanov\virtual\product\12.2.0\dbhome_1\bin\oradim.exe -ACL -setperm diag -USER ORA_OraDB12Home1_SVCACCTS -OBJTYPE dir -OBJPATH C:\app\sivanov\virtual\admin\TX\dpdump -RECURSE false ) 
mkdir C:\app\sivanov\virtual\admin\TX\pfile
if %ERRORLEVEL% == 0 ( C:\app\sivanov\virtual\product\12.2.0\dbhome_1\bin\oradim.exe -ACL -setperm diag -USER ORA_OraDB12Home1_SVCACCTS -OBJTYPE dir -OBJPATH C:\app\sivanov\virtual\admin\TX\pfile -RECURSE false ) 
mkdir C:\app\sivanov\virtual\audit
if %ERRORLEVEL% == 0 ( C:\app\sivanov\virtual\product\12.2.0\dbhome_1\bin\oradim.exe -ACL -setperm diag -USER ORA_OraDB12Home1_SVCACCTS -OBJTYPE dir -OBJPATH C:\app\sivanov\virtual\audit -RECURSE false ) 
mkdir C:\app\sivanov\virtual\cfgtoollogs\dbca\TX
if %ERRORLEVEL% == 0 ( C:\app\sivanov\virtual\product\12.2.0\dbhome_1\bin\oradim.exe -ACL -setperm diag -USER ORA_OraDB12Home1_SVCACCTS -OBJTYPE dir -OBJPATH C:\app\sivanov\virtual\cfgtoollogs\dbca\TX -RECURSE false ) 
mkdir C:\app\sivanov\virtual\oradata\TX
if %ERRORLEVEL% == 0 ( C:\app\sivanov\virtual\product\12.2.0\dbhome_1\bin\oradim.exe -ACL -setperm diag -USER ORA_OraDB12Home1_SVCACCTS -OBJTYPE dir -OBJPATH C:\app\sivanov\virtual\oradata\TX -RECURSE false ) 
mkdir C:\app\sivanov\virtual\product\12.2.0\dbhome_1\database
if %ERRORLEVEL% == 0 ( C:\app\sivanov\virtual\product\12.2.0\dbhome_1\bin\oradim.exe -ACL -setperm diag -USER ORA_OraDB12Home1_SVCACCTS -OBJTYPE dir -OBJPATH C:\app\sivanov\virtual\product\12.2.0\dbhome_1\database -RECURSE false ) 
set PERL5LIB=%ORACLE_HOME%/rdbms/admin;%PERL5LIB%
set ORACLE_SID=TX
set PATH=%ORACLE_HOME%\bin;%ORACLE_HOME%\perl\bin;%PATH%
C:\app\sivanov\virtual\product\12.2.0\dbhome_1\bin\oradim.exe -new -sid TX -startmode manual -spfile 
C:\app\sivanov\virtual\product\12.2.0\dbhome_1\bin\oradim.exe -edit -sid TX -startmode auto -srvcstart system 
C:\app\sivanov\virtual\product\12.2.0\dbhome_1\bin\sqlplus /nolog @C:\tx\New Folder\TX.sql
