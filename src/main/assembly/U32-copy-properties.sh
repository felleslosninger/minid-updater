#!/usr/bin/ksh
#
# Script that will generate MinID updater properties file(s)
# Using templates defined in ./config/
# Concrete values are read from file ./configuration.properties

BASEDIR=`dirname $0`

. ${BASEDIR}/configuration.properties
# Load common functions
. ${BASEDIR}/commonFunctions.sh

MINID_UPDATER_PROPERTIES_TEMPLATE=${BASEDIR}/config/minidUpdater.properties.orig
MINID_PROPERTIES_TEMPLATE=${BASEDIR}/config/minid.properties.orig
APPLICATION_CONTEXT_TEMPLATE=${BASEDIR}/config/applicationContext.xml.orig
BROKER_TEMPLATE=${BASEDIR}/config/applicationContext_brokerTemplate.xml.orig

MINID_UPDATER_PROPERTIES_FILE=${TOMCAT_SHARED_CLASSPATH}/minidUpdater.properties
MINID_PROPERTIES_FILE=${TOMCAT_SHARED_CLASSPATH}/minid.properties
APPLICATION_CONTEXT_FILE=${TOMCAT_SHARED_CLASSPATH}/applicationContext.xml

SED=/usr/bin/sed
MKDIR=/usr/bin/mkdir
AWK=/usr/bin/nawk

#----------------------------------------------------------
modifyMinidUpdaterProperties() {
#----------------------------------------------------------
cmnPrintln "--> Generating '${MINID_UPDATER_PROPERTIES_FILE}' file."

${SED} -e "s|MINID_UPDATER_JMS_CONCURRENT_CONSUMERS|${MINID_UPDATER_JMS_CONCURRENT_CONSUMERS}|" \
	 -e "s|MINID_UPDATER_JMS_MAX_CONCURRENT_CONSUMERS|${MINID_UPDATER_JMS_MAX_CONCURRENT_CONSUMERS}|" \
	 -e "s|MINID_UPDATER_JMS_QUEUE_NAME|${MINID_UPDATER_JMS_QUEUE_NAME}|" \
	 ${MINID_UPDATER_PROPERTIES_TEMPLATE} > ${MINID_UPDATER_PROPERTIES_FILE}

cmnPrintln "<-- File generated"
}

#----------------------------------------------------------
modifyMinidProperties() {
#----------------------------------------------------------
cmnPrintln "--> Generating '${MINID_PROPERTIES_FILE}' file."

${SED} -e "s|MINID_UPDATER_MINID_LDAP_URL|${MINID_UPDATER_MINID_LDAP_URL}|" \
	 -e "s|MINID_UPDATER_MINID_LDAP_USERDN|${MINID_UPDATER_MINID_LDAP_USERDN}|" \
	 -e "s|MINID_UPDATER_MINID_LDAP_PASSWORD|${MINID_UPDATER_MINID_LDAP_PASSWORD}|" \
	 -e "s|MINID_UPDATER_MINID_LDAP_BASE_MINID|${MINID_UPDATER_MINID_LDAP_BASE_MINID}|" \
	 -e "s|MINID_UPDATER_AUDITLOG_DIR|${MINID_UPDATER_AUDITLOG_DIR}|" \
	 -e "s|MINID_UPDATER_AUDITLOG_FILE|${MINID_UPDATER_AUDITLOG_FILE}|" \
	 -e "s|MINID_UPDATER_EVENTLOG_JMS_URL|${MINID_UPDATER_EVENTLOG_JMS_URL}|" \
	 -e "s|MINID_UPDATER_EVENTLOG_JMS_QUEUENAME|${MINID_UPDATER_EVENTLOG_JMS_QUEUENAME}|" \
	 ${MINID_PROPERTIES_TEMPLATE} > ${MINID_PROPERTIES_FILE}

cmnPrintln "<-- File generated"
}

#----------------------------------------------------------
modifyApplicationContext() {
#----------------------------------------------------------
  cmnPrintln "--> Generating '${APPLICATION_CONTEXT_FILE}' file"

  # Splits the APPLICATION_CONTEXT_TEMPLATE file at keyword BROKER_CONTENT_PLACEHOLDER and add FIRST part to APPLICATION_CONTEXT_FILE
  ${AWK} '{if (match($0,"<!--BROKER_CONTENT_PLACEHOLDER-->")) exit; print}' ${APPLICATION_CONTEXT_TEMPLATE} > ${APPLICATION_CONTEXT_FILE}

  brokerIndex=1
  # Loops through all broker urls defined in properties file and create a applicationContext template for each.
  # Each template are added to APPLICATION_CONTEXT_FILE.
  cmnPrintln "--> Start adding broker configuration to applicationProperties. Brokerlist: ${MINID_UPDATER_JMS_BROKER_URL_LIST}"
  for brokerUrl in ${MINID_UPDATER_JMS_BROKER_URL_LIST}
  do
    cmnPrintln "   - Adding broker with URL: ${brokerUrl}"

    ${SED} -e "s|BROKER_INDEX_PLACEHOLDER|${brokerIndex}|" \
           -e 's|BROKER_URL_PLACEHOLDER|'${brokerUrl}'|' \
           ${BROKER_TEMPLATE} \
           >> ${APPLICATION_CONTEXT_FILE}

    printf "\n" >> ${APPLICATION_CONTEXT_FILE}

    (( brokerIndex+=1 ))
  done

  # Splits the APPLICATION_CONTEXT_TEMPLATE file at keyword BROKER_CONTENT_PLACEHOLDER and add LAST part to APPLICATION_CONTEXT_FILE
  ${AWK} '/<!--BROKER_CONTENT_PLACEHOLDER-->/ {p=1;next}; p==1 {print}' ${APPLICATION_CONTEXT_TEMPLATE} >> ${APPLICATION_CONTEXT_FILE}
  
  cmnPrintln "<-- File generated"
}

#----------------------------------------------------------
# MAIN
#----------------------------------------------------------
commonCreateClasspathDirectory
modifyMinidUpdaterProperties
modifyMinidProperties
modifyApplicationContext

cmnPrintln "FINISHED"
cmnPrintln "  - Please restart Tomcat to activate changes."
