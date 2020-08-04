set verify off
ACCEPT sysPassword CHAR PROMPT 'Enter new password for SYS: ' HIDE
ACCEPT systemPassword CHAR PROMPT 'Enter new password for SYSTEM: ' HIDE
host C:\app\sivanov\virtual\product\12.2.0\dbhome_1\bin\orapwd.exe file=C:\app\sivanov\virtual\product\12.2.0\dbhome_1\database\PWDTX.ora force=y format=12
@C:\tx\New Folder\CreateDB.sql
@C:\tx\New Folder\CreateDBFiles.sql
@C:\tx\New Folder\CreateDBCatalog.sql
@C:\tx\New Folder\JServer.sql
@C:\tx\New Folder\lockAccount.sql
@C:\tx\New Folder\postDBCreation.sql
