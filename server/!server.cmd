@rem *****************  Settings ******************* 
@rem Uncomment the following line if you have JDK 7
@rem @set JDK_7_OPTS=-XX:MaxPermSize=1536m
@rem Comment out the following line if you have JDK 7 or JDK 8 below u92
@set JDK_8_OPTS=-XX:+ExitOnOutOfMemoryError
@rem JVM options
@rem  for 64-bit systems:
@set JVM_OPTIONS=-server -Xmx4g -Xms3g -XX:ReservedCodeCacheSize=350m -XX:+HeapDumpOnOutOfMemoryError %JDK_8_OPTS% %JDK_7_OPTS%
@rem  for 32-bit systems:
@rem  @set JVM_OPTIONS=-Xmx1g -XX:MaxPermSize=512m
@rem Additional classpath
@set ADD_CP=
@set STARTER_JAR=starter.jar
@set CP=-cp %STARTER_JAR%;%ADD_CP%
@set STARTER=org.radixware.kernel.starter.Starter
@set STARTER_OPTIONS=-configFile server.cfg
@set PATH=%JAVA_HOME%\bin\;%PATH%
@rem Restart exit code which will be used by application to indicate that it stopped for planned restart
@set RDX_STARTER_RESTART_EXIT_CODE=2
@rem Restart on any non-zero exit code (set to 0 to disable)
@set RESTART_ON_ANY_NONZERO_EXIT_CODE=1
@rem Automatically refresh starter, set 0 to disable
@set AUTO_REFRESH_STARTER=1
@rem Launch dedicated console window for server
@set DEDICATED_CONSOLE_WINDOW=1

@if %DEDICATED_CONSOLE_WINDOW% EQU 1 (
    @if "%THIS_IS_DEDICATED_CONSOLE_WINDOW%"=="" (
        @set THIS_IS_DEDICATED_CONSOLE_WINDOW=1
        start "" %0
        exit
    )
)


@rem Get current date/time for downloaded starter filename (locale independent)
@for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do @set "dt=%%a"
@set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
@set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
@set fullstamp=%YYYY%_%MM%_%DD%_%HH%_%Min%_%Sec%
@set NEW_STARTER_JAR=exported_starter_'%fullstamp%'.jar


:runserver
@rem *****************  Run *******************
@if %AUTO_REFRESH_STARTER% EQU 1 (
    echo Re-exporting starter.jar...      
    java.exe %JVM_OPTIONS% %CP% %STARTER% %STARTER_OPTIONS% export org.radixware/kernel/starter/bin/dist/starter.jar %NEW_STARTER_JAR%
    if exist %NEW_STARTER_JAR% (
        echo Downloaded %NEW_STARTER_JAR%, replacing current starter.jar with it
        move %NEW_STARTER_JAR% %STARTER_JAR%
        if ERRORLEVEL 1 (
            echo Replacement failed, 'move' command exited with status 1
        ) else (
            echo Replacement done
        )
    ) else (
        echo Unable to re-export starter.jar
    )
)

java.exe %JVM_OPTIONS% %CP% %STARTER% %STARTER_OPTIONS%

@set EXIT_CODE=%ERRORLEVEL%
@set DO_RESTART=0

@if %ERRORLEVEL% EQU %RDX_STARTER_RESTART_EXIT_CODE% (
    @set DO_RESTART=1
)

@if %RESTART_ON_ANY_NONZERO_EXIT_CODE% EQU 1 (
    @if not %EXIT_CODE% EQU 0 (
        @set DO_RESTART=1
    )
)

@if %DO_RESTART%==1 (
    echo Server exited with restart exit code %EXIT_CODE%, restarting after 3 seconds
    ping 127.0.0.1 -n 3 > nul
    @if not %ERRORLEVEL% EQU 0 (
        pause
        exit
    )
    goto :runserver
)
