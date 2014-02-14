#!/bin/sh
#
# This script will restart Tomcat
# Depends on configuration property: TOMCAT_HOME

BASEDIR=`dirname $0`

. ${BASEDIR}/../configuration.properties
# Load common functions
. ${BASEDIR}/../commonFunctions.sh

#----------------------------------------------------------
# MAIN
#----------------------------------------------------------
commonStopTomcat
commonStartTomcat

cmnPrintln "FINISHED"
