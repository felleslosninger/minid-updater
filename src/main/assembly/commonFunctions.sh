#!/bin/sh
#
# Script containing common functions used in other scripts.

BASEDIR=`dirname $0`
HOSTNAME=`hostname`

. ${BASEDIR}/internal/internal.properties
. ${BASEDIR}/configuration.properties

#----------------------------------------------------------
cmnPrintln() {
#----------------------------------------------------------
# Print text in green color
printf "\033[1;32m[MINIDUPDATER] $1\033[m\n"
}

#----------------------------------------------------------
cmnErrln() {
#----------------------------------------------------------
# Print text in red color
printf "\033[1;31m[MINIDUPDATER] $1\033[m\n"
}


#----------------------------------------------------------
commonCreateClasspathDirectory() {
#----------------------------------------------------------
cmnPrintln "--> Creating '${TOMCAT_SHARED_CLASSPATH}'"
if [ ! -d ${TOMCAT_SHARED_CLASSPATH} ]; then
	${MKDIR} ${TOMCAT_SHARED_CLASSPATH}
else
	cmnPrintln "  - The directory ${TOMCAT_SHARED_CLASSPATH} already exists."
fi
cmnPrintln "<-- '${TOMCAT_SHARED_CLASSPATH}' created"
}


#----------------------------------------------------------
commonCreateClasspathConfigDirectory() {
#----------------------------------------------------------
cmnPrintln "--> Creating '${TOMCAT_SHARED_CLASSPATH}/config'"
if [ ! -d ${TOMCAT_SHARED_CLASSPATH}/config ]; then
	${MKDIR} ${TOMCAT_SHARED_CLASSPATH}/config
else
	cmnPrintln "  - The directory ${TOMCAT_SHARED_CLASSPATH}/config already exists."
fi
cmnPrintln "<-- '${TOMCAT_SHARED_CLASSPATH}/config' created"
}

#----------------------------------------------------------
setCatalinaPid() {
#----------------------------------------------------------
export CATALINA_PID=${TOMCAT_HOME}/bin/tomcat_pid
}

#----------------------------------------------------------
commonStopTomcat() {
#----------------------------------------------------------
cmnPrintln "--> Stopping Tomcat Server"
setCatalinaPid

STATUS=0
if [ -f $CATALINA_PID ];
then
   cmnPrintln "CATALINA_PID set to $CATALINA_PID"
   ${TOMCAT_HOME}/bin/shutdown.sh 10 -force
   STATUS=$?
   if [ -f $CATALINA_PID ]; then
       # pid file where not deleted by tomcat. Most likely because of errror. Remove it to prevent wrong pid from failing restart next time.
       rm $CATALINA_PID
   fi   
else
   cmnErrln "CATALINA_PID file doesn't exist. Will wait 10 seconds after shutdown."
   export CATALINA_PID=
   ${TOMCAT_HOME}/bin/shutdown.sh 10
   STATUS=$?
   sleep 10
fi

if [ $STATUS != 0 ]; then
	cmnErrln "Tomcat shutdown failed!"
fi

cmnPrintln "<-- Tomcat Server stopped"
}

#----------------------------------------------------------
commonStartTomcat() {
#----------------------------------------------------------
cmnPrintln "--> Starting Tomcat Server"
setCatalinaPid
${TOMCAT_HOME}/bin/startup.sh 20 -force
cmnPrintln "<-- Tomcat Server started"
}

# Print common information for all scripts
cmnPrintln "======================================================================"
cmnPrintln "MinID Updater script $0 initiated"
cmnPrintln "======================================================================"
USERID=`id`
cmnPrintln "UserID: ${USERID}"
cmnPrintln "Server: ${HOSTNAME}"