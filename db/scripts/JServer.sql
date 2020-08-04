SET VERIFY OFF
connect "SYS"/"&&sysPassword" as SYSDBA
set echo on
spool C:\tx\New Folder\JServer.log append
@C:\app\sivanov\virtual\product\12.2.0\dbhome_1\javavm\install\initjvm.sql;
@C:\app\sivanov\virtual\product\12.2.0\dbhome_1\xdk\admin\initxml.sql;
@C:\app\sivanov\virtual\product\12.2.0\dbhome_1\xdk\admin\xmlja.sql;
@C:\app\sivanov\virtual\product\12.2.0\dbhome_1\rdbms\admin\catjava.sql;
connect "SYS"/"&&sysPassword" as SYSDBA
@C:\app\sivanov\virtual\product\12.2.0\dbhome_1\rdbms\admin\catxdbj.sql;
spool off
connect "SYS"/"&&sysPassword" as SYSDBA
set echo on
spool C:\tx\New Folder\postDBCreation.log append
create or replace directory ORACLE_HOME as 'C:\app\sivanov\virtual\product\12.2.0\dbhome_1';
create or replace directory ORACLE_BASE as 'C:\app\sivanov\virtual';
grant sysdg to sysdg;
grant sysbackup to sysbackup;
grant syskm to syskm;
