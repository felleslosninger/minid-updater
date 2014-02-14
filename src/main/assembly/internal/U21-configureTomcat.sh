#!/bin/sh
#
# Script that will create setenv.sh in ${TOMCAT_HOME}/bin.
# JAVA_OPTS and JAVA_HOME are set here.
# Set configuration data in configuration.properties
# Depends on configuration properties:
# - TOMCAT_HOME
# - TOMCAT_JAVA_HOME
# - TOMCAT_JAVA_OPTS
# - TOMCAT_HTTP_PORT

BASEDIR=`dirname $0`

# Load common functions and configuration properties
. ${BASEDIR}/../commonFunctions.sh

WGET=/bin/wget
SED=/bin/sed
TAR=/bin/gtar

SETENV_TEMPLATE=${BASEDIR}/config/setenv.sh.orig
SETENV_FILE=${TOMCAT_HOME}/bin/setenv.sh
SERVER_TEMPLATE=${BASEDIR}/config/server.xml.orig
SERVER_FILE=${TOMCAT_HOME}/conf/server.xml

#----------------------------------------------------------
generateSetenv() {
#----------------------------------------------------------
cmnPrintln "--> Generating ${SETENV_FILE}"

${SED} -e "s|TOMCAT_JAVA_HOME|${TOMCAT_JAVA_HOME}|" \
	 -e "s|TOMCAT_JAVA_OPTS|${TOMCAT_JAVA_OPTS}|" \
	 ${SETENV_TEMPLATE} > ${SETENV_FILE}

cmnPrintln "<-- File generated"
}

#----------------------------------------------------------
generateServerXml() {
#----------------------------------------------------------
cmnPrintln "--> Generating ${SERVER_FILE}"

${SED} -e "s|TOMCAT_HTTP_PORT|${TOMCAT_HTTP_PORT}|" \
	-e "s|GENERATED_TIMESTAMP|$(date)|" \
	 ${SERVER_TEMPLATE} > ${SERVER_FILE}

cmnPrintln "<-- File generated"
}

#----------------------------------------------------------
# MAIN
#----------------------------------------------------------
generateSetenv
generateServerXml

cmnPrintln "FINISHED"
