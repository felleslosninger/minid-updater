#params.pp
class minid_updater::params {
  $server_tomcat_max_threads        = 200
  $server_tomcat_min_threads        = 10
  $eventlog_jms_url                 = hiera('platform::jms_url')
  $eventlog_jms_queuename           = hiera('idporten_logwriter::jms_queueName')
  $ldap_url                         = hiera('idporten_opensso_opendj::url')
  $ldap_userdn                      = hiera('idporten_opensso_opendj::dn')
  $ldap_password                    = hiera('idporten_opensso_opendj::password')
  $ldap_base_minid                  = hiera('idporten_opensso_opendj::minid_base')
  $update_jms_queuename             = hiera('minid_updater::update_jms_queuename')
  $event_jms_concurrent_consumers   = 1
  $event_jms_max_concurrent_consumers = 1
  $log_level                = 'WARN'
  $server_port                = 9990
  $config_root                = '/etc/opt/'
  $log_root                   = '/var/log/'
  $module                     = 'minid_updater'
  $application                = 'minid-updater'
  $artifact_id                = 'minid-updater'
  $context                    = 'minid-updater'
  $service_name               = 'minid-updater'
  $config_dir                                  = '/etc/opt/'
  $install_dir                                 = '/opt/'
}
