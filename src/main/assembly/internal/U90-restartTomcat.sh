#!/bin/sh
#
# This script will restart Tomcat
# Depends on configuration property: TOMCAT_HOME

# Base directory for installation set
BASEDIR=$(dirname $(dirname $(readlink -f $0)))

# Load common functions and configuration properties
. $BASEDIR/configuration.properties

# Load common functions
. ${BASEDIR}/commonFunctions.sh

#----------------------------------------------------------
# MAIN
#----------------------------------------------------------
commonStopTomcat
commonStartTomcat

cmnPrintln "FINISHED"
