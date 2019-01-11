class minid_updater (
  $tomcat_instance            = $minid_updater::params::tomcat_instance,

  $tomcat_details             = $minid_updater::params::tomcat_details,
  $tomcat_user                = $minid_updater::params::tomcat_user,
  $tomcat_group               = $minid_updater::params::tomcat_group,
  $eventlog_jms_url           = $minid_updater::params::eventlog_jms_url,
  $eventlog_jms_queuename     = $minid_updater::params::eventlog_jms_queuename,
  $ldap_url                   = $minid_updater::params::ldap_url,
  $ldap_userdn                = $minid_updater::params::ldap_userdn,
  $ldap_password              = $minid_updater::params::ldap_password,
  $ldap_base_minid            = $minid_updater::params::ldap_base_minid,
  $update_jms_queuename       = $minid_updater::params::update_jms_queuename,
  $log_level                  = $minid_updater::params::log_level,
  $config_root                = $minid_updater::params::config_root,
  $log_root                   = $minid_updater::params::log_root,
  $module                     = $minid_updater::params::module,
  $application                = $minid_updater::params::application,
  $context                    = $minid_updater::params::context,
)inherits minid_updater::params {

  include platform

  validate_string($tomcat_user)
  validate_string($tomcat_group)
  validate_hash($tomcat_details)
  validate_string($eventlog_jms_url)
  validate_string($eventlog_jms_queuename)
  validate_string($log_level)
  validate_string($module)
  validate_string($application)
  validate_string($context)

  anchor { 'minid_updater::begin': } ->
  class { '::minid_updater::install': } ->
  class { '::minid_updater::deploy': } ->
  class { '::minid_updater::config': } ~>
  class { '::minid_updater::service': } ->
  anchor { 'minid_updater::end': }

}