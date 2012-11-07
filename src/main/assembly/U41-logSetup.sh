#!/usr/bin/ksh
#
# Script that will generate Minid updater LOG4J.XML
# Using template defined in ./config/
# Concrete values are read from file ./configuration.properties

BASEDIR=`dirname $0`

. ${BASEDIR}/configuration.properties
# Load common functions
. ${BASEDIR}/commonFunctions.sh

LOG4J_XML_TEMPLATE=${BASEDIR}/config/log4j.xml.orig
LOG4J_XML_FILE=${TOMCAT_SHARED_CLASSPATH}/log4j.xml

SED=/usr/bin/sed
MKDIR=/usr/bin/mkdir

#----------------------------------------------------------
modifylog4jXml() {
#----------------------------------------------------------
cmnPrintln "--> Generating '${LOG4J_XML_FILE}' file."
${SED}  -e "s|MINID_UPDATER_LOG_DIR|${MINID_UPDATER_LOG_DIR}|" \
		-e "s|MINID_UPDATER_LOG_FILE|${MINID_UPDATER_LOG_FILE}|" \
		-e "s|MINID_UPDATER_LOG_LEVEL|${MINID_UPDATER_LOG_LEVEL}|" \
	${LOG4J_XML_TEMPLATE} > ${LOG4J_XML_FILE}

cmnPrintln "<-- File generated"
}

#----------------------------------------------------------
# MAIN
#----------------------------------------------------------
commonCreateClasspathDirectory
modifylog4jXml

cmnPrintln "FINISHED"
cmnPrintln "  - Please restart Tomcat to activate LOG4J changes."
