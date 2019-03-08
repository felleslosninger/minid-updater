class minid_updater (
  String $eventlog_jms_url           = $minid_updater::params::eventlog_jms_url,
  String $eventlog_jms_queuename     = $minid_updater::params::eventlog_jms_queuename,
  String $ldap_url                   = $minid_updater::params::ldap_url,
  String $ldap_userdn                = $minid_updater::params::ldap_userdn,
  String $ldap_password              = $minid_updater::params::ldap_password,
  String $ldap_base_minid            = $minid_updater::params::ldap_base_minid,
  String $update_jms_queuename       = $minid_updater::params::update_jms_queuename,
  String $log_level                  = $minid_updater::params::log_level,
  String $config_root                = $minid_updater::params::config_root,
  String $log_root                   = $minid_updater::params::log_root,
  String $application                = $minid_updater::params::application,
  String $context                    = $minid_updater::params::context,

)inherits minid_updater::params {

  include platform

  anchor { 'minid_updater::begin': } ->
  class { '::minid_updater::install': } ->
  class { '::minid_updater::deploy': } ->
  class { '::minid_updater::config': } ~>
  class { '::minid_updater::service': } ->
  anchor { 'minid_updater::end': }

}