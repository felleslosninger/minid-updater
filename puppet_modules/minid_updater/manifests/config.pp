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
    target => "${minid_updater::install_dir}${minid_updater::application}/${minid_updater::application}.war",
  }

  file { "${minid_updater::config_root}${minid_updater::application}/minidUpdater.properties":
    ensure  => 'file',
    content => template("${minid_updater::module}/minidUpdater.properties.erb"),
    owner   => $minid_updater::service_name,
    group   => $minid_updater::service_name,
    mode    => '0644',
  } ->
  file { "${minid_updater::config_root}${minid_updater::application}/minid.properties":
    ensure  => 'file',
    content => template("${minid_updater::module}/minid.properties.erb"),
    owner   => $minid_updater::service_name,
    group   => $minid_updater::service_name,
    mode    => '0644',
  } ->
  file { "${minid_updater::config_root}${minid_updater::application}/log4j.xml":
    ensure  => 'absent',
  } ->
  file { "${minid_updater::config_root}${minid_updater::application}/logback.xml":
    ensure  => 'file',
    content => template("${minid_updater::module}/logback.xml.erb"),
    owner   => $minid_updater::service_name,
    group   => $minid_updater::service_name,
    mode    => '0644',
  }

}