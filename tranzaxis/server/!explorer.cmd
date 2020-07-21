@rem *****************  Settings *******************
@set JVM_OPTIONS=-Xmx3g
@set STARTER=-jar starter.jar
@set STARTER_JAR=starter.jar  
@set STARTER_OPTIONS=-configFile explorer.cfg
@set PATH=%JAVA_HOME%\bin\;%PATH%
@set AUTO_REFRESH_STARTER="1"

:: Starter auto refresh configuration
:: Get current date/time for downloaded starter filename (locale independent)
@for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do @set "dt=%%a"
@set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
@set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
@set fullstamp=%YYYY%_%MM%_%DD%_%HH%_%Min%_%Sec%
@set NEW_STARTER_JAR=exported_starter_'%fullstamp%'.jar


@rem *****************  Run *******************
@if %AUTO_REFRESH_STARTER% == "1" (
    echo Re-exporting starter.jar...      
    java.exe %JVM_OPTIONS% %STARTER% %STARTER_OPTIONS% export org.radixware/kernel/starter/bin/dist/starter.jar %NEW_STARTER_JAR%
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

start java.exe %JVM_OPTIONS% %STARTER% %STARTER_OPTIONS%
