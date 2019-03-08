class minid_updater::config inherits minid_updater{

  file { "${minid_updater::config_dir}${minid_updater::application}/application.yaml":
    ensure  => 'file',
    content => template("${module_name}/application.yaml.erb"),
    owner   => $minid_updater::service_name,
    group   => $minid_updater::service_name,
    mode    => '0444',
  } ->
  file { "${minid_updater::install_dir}${minid_updater::application}/${minid_updater::application}.conf":
    ensure  => 'file',
    content => template("${module_name}/minid_updater.conf.erb"),
    owner   => $minid_updater::service_name,
    group   => $minid_updater::service_name,
    mode    => '0444',
  } ->
  file { "/etc/rc.d/init.d/${minid_updater::service_name}":
    ensure => 'link',
    target => "${minid_updater::install_dir}${minid_updater::application}/${minid_updater::application}.jar",
  }

  difilib::logback_config { $minid_updater::application:
    application       => $minid_updater::application,
    owner             => $minid_updater::service_name,
    group             => $minid_updater::service_name,
    loglevel_no       => $minid_updater::log_level,
    loglevel_nondifi  => $minid_updater::log_level,
  }

}