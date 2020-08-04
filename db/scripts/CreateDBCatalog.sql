SET VERIFY OFF
connect "SYS"/"&&sysPassword" as SYSDBA
set echo on
spool C:\tx\New Folder\CreateDBCatalog.log append
@C:\app\sivanov\virtual\product\12.2.0\dbhome_1\rdbms\admin\catalog.sql;
@C:\app\sivanov\virtual\product\12.2.0\dbhome_1\rdbms\admin\catproc.sql;
@C:\app\sivanov\virtual\product\12.2.0\dbhome_1\rdbms\admin\catoctk.sql;
@C:\app\sivanov\virtual\product\12.2.0\dbhome_1\rdbms\admin\owminst.plb;
connect "SYSTEM"/"&&systemPassword"
@C:\app\sivanov\virtual\product\12.2.0\dbhome_1\sqlplus\admin\pupbld.sql;
connect "SYSTEM"/"&&systemPassword"
set echo on
spool C:\tx\New Folder\sqlPlusHelp.log append
@C:\app\sivanov\virtual\product\12.2.0\dbhome_1\sqlplus\admin\help\hlpbld.sql helpus.sql;
spool off
spool off
