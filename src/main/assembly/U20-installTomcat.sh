#!/usr/bin/ksh
#
# Script that will download tomcat, unzip it and modify configuration.
# Set configuration data in configuration.properties
# Depends on configuration properties:
# - TOMCAT_HOME
# - TOMCAT_VERSION
# - TOMCAT_WGET_URL_DIRECTORY

BASEDIR=`dirname $0`

# Load common functions and configuration properties
. ${BASEDIR}/commonFunctions.sh

WGET=/usr/sfw/bin/wget
SED=/usr/bin/sed
TAR=/usr/sfw/bin/gtar

TOMCAT_NAME=apache-tomcat-${TOMCAT_VERSION}
TOMCAT_ZIPPED_NAME=${TOMCAT_NAME}.tar.gz
TOMCAT_INSTALL_PATH=/opt
TOMCAT_DOWNLOAD_PATH=${TOMCAT_INSTALL_PATH}/${TOMCAT_ZIPPED_NAME}
TOMCAT_UNZIPPED_PATH=${TOMCAT_INSTALL_PATH}/${TOMCAT_NAME}

#----------------------------------------------------------
downloadTomcat() {
#----------------------------------------------------------
cmnPrintln "--> Downloading ${TOMCAT_ZIPPED_NAME}."
rm ${TOMCAT_DOWNLOAD_PATH}
${WGET} -O ${TOMCAT_DOWNLOAD_PATH} ${TOMCAT_WGET_URL_DIRECTORY}/${TOMCAT_ZIPPED_NAME}
cmnPrintln "<-- File downloaded to ${TOMCAT_DOWNLOAD_PATH}"
}

#----------------------------------------------------------
unzipTomcat() {
#----------------------------------------------------------
cmnPrintln "--> Unzipping ${TOMCAT_DOWNLOAD_PATH}."
# See if Tomcat already installed
if [ -d ${TOMCAT_UNZIPPED_PATH} ]; then
	cmnErrln "${TOMCAT_UNZIPPED_PATH} already exists. Please delete and try again."
	exit 1
fi

${TAR} -C ${TOMCAT_INSTALL_PATH} -zxf ${TOMCAT_DOWNLOAD_PATH}
cmnPrintln "  - Unzip OK, deleting zip file"
rm ${TOMCAT_DOWNLOAD_PATH}
cmnPrintln "<-- File unzipped OK"
}

#----------------------------------------------------------
createSymlinkTomcat() {
#----------------------------------------------------------
cmnPrintln "--> Creating symlink ${TOMCAT_HOME}."
rm ${TOMCAT_HOME}
ln -s ${TOMCAT_UNZIPPED_PATH} ${TOMCAT_HOME}
cmnPrintln "<-- Symlink created OK"
}

#----------------------------------------------------------
# MAIN
#----------------------------------------------------------
downloadTomcat
unzipTomcat
createSymlinkTomcat

cmnPrintln "FINISHED"
