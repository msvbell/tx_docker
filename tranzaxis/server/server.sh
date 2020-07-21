#!/bin/sh

# ******************** Settings ***********************
#Uncomment the following line if you have JDK 7
#export JDK_7_OPTIONS=-XX:MaxPermSize=1536m
#Comment out the following line if you use JDK 8
export JDK_8_OPTIONS=-XX:+ExitOnOutOfMemoryError
# JVM options
#  for 32-bit systems:
#export JVM_OPTIONS="-server -Xmx1g -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError"
#  for 64-bit systems:
export JVM_OPTIONS="-Xmx4g -Xms3g -XX:ReservedCodeCacheSize=350m -XX:+HeapDumpOnOutOfMemoryError $JDK_7_OPTIONS $JDK_8_OPTIONS"
# Additional classpath, place : before first entry and between etries
export ADD_CP=""
# Name of the starter 
export STARTER_JAR="starter.jar"
# Automatically refresh starter
export AUTO_REFRESH_STARTER="1" #0 to disable, 1 to enable
# Temporary name for new starter
export NEW_STARTER_JAR="exported_starter_`date -u +%Y_%M_%d_%H_%m_%S`.jar"
# Restart exit code which will be used by application to indicate that it stopped for planned restart
export RDX_STARTER_RESTART_EXIT_CODE=2
# Restart on any non-zero exit code (set to 0 to disable)
export RESTART_ON_ANY_NONZERO_EXIT_CODE=1


# *****************  Run ******************* 
export CP="-cp /app/server/starter.jar"$ADD_CP
export STARTER="org.radixware.kernel.starter.Starter"
export STARTER_OPTIONS="-configFile /app/server/server.cfg"


updateStarter() {
    if [ "$AUTO_REFRESH_STARTER" -eq "1" ] ; then
        echo "Re-exporting starter.jar..."
        java $JVM_OPTIONS $CP $STARTER $STARTER_OPTIONS export org.radixware/kernel/starter/bin/dist/starter.jar $NEW_STARTER_JAR
        if [ -e "$NEW_STARTER_JAR" ] ; then
            echo "Downloaded $NEW_STARTER_JAR, replacing current starter.jar with it"
            mv $NEW_STARTER_JAR $STARTER_JAR
            mv_code="$?"
            if [ "$mv_code" -eq "0" ] ; then
                echo "Replacement done"
            else
                echo "Replacement failed, 'mv' command exited with status $mv_code"
            fi
        else
            echo "Unable to re-export starter.jar";    
        fi
    fi
}


COMMAND="java $JVM_OPTIONS $CP $STARTER $STARTER_OPTIONS"

while true
do
    updateStarter
    eval "$COMMAND"
    exit_code=$?
    if [ $exit_code -eq $RDX_STARTER_RESTART_EXIT_CODE ] || ([ $RESTART_ON_ANY_NONZERO_EXIT_CODE -eq 1 ] && [ $exit_code -gt 0 ]) ; then
        echo "`date`: server process exited with restart code $exit_code, restarting after 3 seconds"   
        sleep 3
    else
        echo "`date`: server process exited with code $exit_code, terminating" 
        exit $exit_code
    fi
done
