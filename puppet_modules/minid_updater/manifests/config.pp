class minid_updater::config inherits minid_updater{

  file { "${minid_updater::config_root}${minid_updater::application}/minidUpdater.properties":
    ensure  => 'file',
    content => template("${minid_updater::module}/minidUpdater.properties.erb"),
    owner   => $minid_updater::tomcat_user,
    group   => $minid_updater::tomcat_group,
    mode    => '0644',
  } ->
  file { "${minid_updater::config_root}${minid_updater::application}/minid.properties":
    ensure  => 'file',
    content => template("${minid_updater::module}/minid.properties.erb"),
    owner   => $minid_updater::tomcat_user,
    group   => $minid_updater::tomcat_group,
    mode    => '0644',
  } ->
  file { "${minid_updater::config_root}${minid_updater::application}/log4j.xml":
    ensure  => 'absent',
  } ->
  file { "${minid_updater::config_root}${minid_updater::application}/logback.xml":
    ensure  => 'file',
    content => template("${minid_updater::module}/logback.xml.erb"),
    owner   => $minid_updater::tomcat_user,
    group   => $minid_updater::tomcat_group,
    mode    => '0644',
  } ->
  file { "${minid_updater::config_root}${minid_updater::application}/applicationContext.xml":
    ensure  => 'file',
    content => template("${minid_updater::module}/applicationContext.xml.erb"),
    owner   => $minid_updater::tomcat_user,
    group   => $minid_updater::tomcat_group,
    mode    => '0644',
  }

}