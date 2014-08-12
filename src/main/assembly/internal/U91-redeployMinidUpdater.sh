#!/bin/sh
#
# This script will redeploy minid updater WAR in tomcat.
# Depends on configuration properties: 
# - TOMCAT_HOME 
# - MINID_UPDATER_WAR
# - MINID_UPDATER_CONTEXT_ROOT

# Base directory for installation set
BASEDIR=$(dirname $(dirname $(readlink -f $0)))

# Load common functions and configuration properties
. $BASEDIR/configuration.properties

# Load common functions
. ${BASEDIR}/commonFunctions.sh

TOMCAT_WAR_PATH=${TOMCAT_HOME}/webapps/${MINID_UPDATER_CONTEXT_ROOT}
TOMCAT_WAR_FILE=${TOMCAT_WAR_PATH}.war

#----------------------------------------------------------
# MAIN
#----------------------------------------------------------

# Stop tomcat with common function from commonFunctions.sh
commonStopTomcat

cmnPrintln "--> Delete existing Minid updater from Tomcat"
if [ ! -f ${TOMCAT_WAR_FILE} ]; then
	cmnPrintln "  - ${TOMCAT_WAR_FILE} not found."
	cmnPrintln "  - Skip delete of war file"	
else
	rm ${TOMCAT_WAR_FILE}
fi
if [ ! -d ${TOMCAT_WAR_PATH} ]; then
	cmnPrintln "  - Directory ${TOMCAT_WAR_PATH} not found."
	cmnPrintln "  - Skip delete of exploded war"	
else
	rm -r ${TOMCAT_WAR_PATH}
fi
cmnPrintln "<-- Minid Updater deleted from Tomcat"

cmnPrintln "--> Copying Minid updater to Tomcat"
cmnPrintln "  - From: ${MINID_UPDATER_WAR}"
cmnPrintln "  - To: ${TOMCAT_WAR_FILE}"
cp ${MINID_UPDATER_WAR} ${TOMCAT_WAR_FILE}
cmnPrintln "<-- Minid updater copied to Tomcat"

# Start tomcat with common function from commonFunctions.sh
commonStartTomcat

cmnPrintln "FINISHED"
