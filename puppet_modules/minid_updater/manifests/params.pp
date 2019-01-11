#params.pp
class minid_updater::params {
  $tomcat_instance            = hiera('minid_updater::tomcat_instance')
  $tomcat_details             = hiera('tomcat::instances::instances')
  $tomcat_user                = $tomcat_details["$tomcat_instance"]['user']
  $tomcat_group               = $tomcat_details["$tomcat_instance"]['group']
  $eventlog_jms_url           = hiera('platform::jms_url')
  $eventlog_jms_queuename     = hiera('idporten_logwriter::jms_queueName')
  $ldap_url                   = hiera('idporten_opensso_opendj::url')
  $ldap_userdn                = hiera('idporten_opensso_opendj::dn')
  $ldap_password              = hiera('idporten_opensso_opendj::password')
  $ldap_base_minid            = hiera('idporten_opensso_opendj::minid_base')
  $update_jms_queuename       = hiera('minid_updater::update_jms_queuename')
  $log_level                = 'WARN'
  $config_root                = '/etc/opt/'
  $log_root                   = '/var/log/'
  $module                     = 'minid_updater'
  $application                = 'minid-updater'
  $context                    = 'minid-updater'
}
