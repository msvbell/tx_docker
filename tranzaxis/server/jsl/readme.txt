To run RadixWare Server as Windows service Java Service Launcher (for Windows) 
can be used.
see http://jslwin.sourceforge.net/

Modify config file jsl.ini for x86 platforms or
jsl64.ini for amd/intel 64-bit platforms.


If you get error like 'The application has failed to start because its side-by-side configuration is incorrect. 
Please see the application event log or use the command-line sxstrace.exe tool for more detail.', 
then your system is probaly missing  required Visual C++ runtime files (msvcp90.dll, msvcr90.dll, 
Microsoft.VC90.CRT.manifest). You should install requred runtime components to the system, or place this files
near jsl.exe 

To test config run:
jsl -debug  
or 
jsl64 -debug


To install service run 
jsl -install
or 
jsl64 -install


To uninstall service run 
jsl -remove
or 
jsl64 -remove
