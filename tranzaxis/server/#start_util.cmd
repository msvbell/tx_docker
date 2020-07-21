@set JVM_OPTIONS=-Xmx512m -XX:MaxPermSize=192m
@set STARTER=-jar starter.jar
@set STARTER_ARGS=-svnHomeUrl=%SVN_URL% -topLayerUri=com.tranzaxis -homedir=%HOME_DIR% %SVN_AUTH%
@set PATH=%JAVA_HOME%\bin\;%PATH%

start java %JVM_OPTIONS% %STARTER% %STARTER_ARGS% %CLASS% %APP_ARGS%
