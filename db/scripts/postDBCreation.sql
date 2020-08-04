SET VERIFY OFF
spool C:\tx\New Folder\postDBCreation.log append
host C:\app\sivanov\virtual\product\12.2.0\dbhome_1\OPatch\datapatch.bat -skip_upgrade_check -db TX;
connect "SYS"/"&&sysPassword" as SYSDBA
set echo on
create spfile='C:\app\sivanov\virtual\product\12.2.0\dbhome_1\database\spfileTX.ora' FROM pfile='C:\tx\New Folder\init.ora';
connect "SYS"/"&&sysPassword" as SYSDBA
select 'utlrp_begin: ' || to_char(sysdate, 'HH:MI:SS') from dual;
@C:\app\sivanov\virtual\product\12.2.0\dbhome_1\rdbms\admin\utlrp.sql;
select 'utlrp_end: ' || to_char(sysdate, 'HH:MI:SS') from dual;
select comp_id, status from dba_registry;
shutdown immediate;
connect "SYS"/"&&sysPassword" as SYSDBA
startup ;
spool off
exit;
