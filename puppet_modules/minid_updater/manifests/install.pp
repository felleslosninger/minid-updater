#install.pp
class minid_updater::install inherits minid_updater {

  if ($platform::install_cron_jobs) {
    $log_cleanup_command = "find ${minid_updater::log_root}${minid_updater::application}/ -type f -name \"*.gz\" -mtime +7 -exec rm -f {} \\;"
    $auditlog_cleanup_command= "find /var/log/${minid_updater::application}/ -type f -name \"*minid-updater.log\" -mtime +7 -exec rm -f {} \\;"

    cron { "${minid_updater::application}_log_cleanup":
      command => $log_cleanup_command,
      user    => 'root',
      hour    => '03',
      minute  => '00',
    }
    cron { "${minid_updater::application}_log_cleanup_audit":
      command => $auditlog_cleanup_command,
      user    => 'root',
      hour    => '03',
      minute  => '20',
    }
  }

  file { "${minid_updater::config_root}${minid_updater::application}":
    ensure => 'directory',
    owner  => $minid_updater::tomcat_user,
    group  => $minid_updater::tomcat_group,
    mode   => '0755',
  } ->
  file { "${minid_updater::log_root}${minid_updater::application}":
    ensure => 'directory',
    owner  => $minid_updater::tomcat_user,
    group  => $minid_updater::tomcat_group,
    mode   => '0755',
  }
}
