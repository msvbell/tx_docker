#!/bin/sh

# *****************  Settings ******************* 
export JVM_OPTIONS="-Xmx1g -XX:MaxPermSize=256m"
export CP="-cp starter.jar:$ADD_CP"
export STARTER_JAR="starter.jar"
export STARTER="org.radixware.kernel.starter.Starter"
export STARTER_OPTIONS="-configFile explorer.cfg"

# Starter auto refresh configuration
export AUTO_REFRESH_STARTER="1" #0 to disable, 1 to enable
export NEW_STARTER_JAR="exported_starter_`date -u +%Y_%M_%d_%H_%m_%S`.jar"


# *****************  Run ******************* 
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

java $JVM_OPTIONS $CP $STARTER $STARTER_OPTIONS 
