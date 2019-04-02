class minid_updater (
  String $java_home                  = $minid_updater::params::java_home,
  String $eventlog_jms_url           = $minid_updater::params::eventlog_jms_url,
  String $eventlog_jms_queuename     = $minid_updater::params::eventlog_jms_queuename,
  String $ldap_url                   = $minid_updater::params::ldap_url,
  String $ldap_userdn                = $minid_updater::params::ldap_userdn,
  String $ldap_password              = $minid_updater::params::ldap_password,
  String $ldap_base_minid            = $minid_updater::params::ldap_base_minid,
  String $update_jms_queuename       = $minid_updater::params::update_jms_queuename,
  String $log_level                  = $minid_updater::params::log_level,
  String $config_dir                 = $minid_updater::params::config_dir,
  String $install_dir                = $minid_updater::params::install_dir,
  String $log_root                   = $minid_updater::params::log_root,
  String $application                = $minid_updater::params::application,
  String $context                    = $minid_updater::params::context,
  String $artifact_id                = $minid_updater::params::artifact_id ,
  String $service_name               = $minid_updater::params::service_name,
  Integer $server_port               = $minid_updater::params::server_port,
  Integer $server_tomcat_max_threads              = $minid_updater::params::server_tomcat_max_threads,
  Integer $server_tomcat_min_spare_threads        = $minid_updater::params::server_tomcat_min_spare_threads,
  Integer $event_jms_concurrent_consumers         = $minid_updater::params::event_jms_concurrent_consumers,
  Integer $event_jms_max_concurrent_consumers     = $minid_updater::params::event_jms_max_concurrent_consumers,


)inherits minid_updater::params {

  include platform

  anchor { 'minid_updater::begin': } ->
  class { '::minid_updater::install': } ->
  class { '::minid_updater::deploy': } ->
  class { '::minid_updater::config': } ~>
  class { '::minid_updater::service': } ->
  anchor { 'minid_updater::end': }

}