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

  user { $minid_updater::service_name:
    ensure => present,
    shell  => '/sbin/nologin',
    home   => '/',
  } ->
  file { "${minid_updater::config_dir}${minid_updater::application}":
    ensure => 'directory',
    mode   => '0755',
    owner  => $minid_updater::service_name,
    group  => $minid_updater::service_name,
  } ->
  file { "${minid_updater::config_dir}${minid_updater::application}/config":
    ensure => 'directory',
    owner  => $minid_updater::service_name,
    group  => $minid_updater::service_name,
    mode   => '0755',
  } ->
  file { "${minid_updater::config_dir}${minid_updater::application}/messages":
    ensure => 'directory',
    owner  => $minid_updater::service_name,
    group  => $minid_updater::service_name,
    mode   => '0755',
  } ->
  file { "${minid_updater::log_root}${minid_updater::application}":
    ensure => 'directory',
    mode   => '0755',
    owner  => $minid_updater::service_name,
    group  => $minid_updater::service_name,
  } ->
  file { "${minid_updater::log_root}${minid_updater::application}/audit":
    ensure => 'directory',
    mode   => '0755',
    owner  => $minid_updater::service_name,
    group  => $minid_updater::service_name,
  } ->
  file { "${minid_updater::install_dir}${minid_updater::application}":
    ensure => 'directory',
    mode   => '0644',
    owner  => $minid_updater::service_name,
    group  => $minid_updater::service_name,
  }

  difilib::spring_boot_logrotate { $minid_updater::application:
    application => $minid_updater::application,
  }
}
