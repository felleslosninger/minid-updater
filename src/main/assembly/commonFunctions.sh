#!/usr/bin/ksh
#
# Script containing common functions used in other scripts.

BASEDIR=`dirname $0`
HOSTNAME=`hostname`

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
commonStopTomcat() {
#----------------------------------------------------------
cmnPrintln "--> Stopping Tomcat Server"
${TOMCAT_HOME}/bin/shutdown.sh
cmnPrintln "<-- Tomcat Server stopped"
}

#----------------------------------------------------------
commonStartTomcat() {
#----------------------------------------------------------
cmnPrintln "--> Starting Tomcat Server"
${TOMCAT_HOME}/bin/startup.sh
cmnPrintln "<-- Tomcat Server started"
}

# Print common information for all scripts
cmnPrintln "======================================================================"
cmnPrintln "MinID Updater script $0 initiated"
cmnPrintln "======================================================================"
USERID=`id`
cmnPrintln "UserID: ${USERID}"
cmnPrintln "Server: ${HOSTNAME}"