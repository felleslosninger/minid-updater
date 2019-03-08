#deploy.pp

class minid_updater::deploy inherits minid_updater {

  include 'difilib'

  difilib::spring_boot_deploy { $minid_updater::application:
    package         => 'no.idporten',
    artifact        => 'minid-updater',
    service_name  => $minid_updater::service_name,
    install_dir   => "${minid_updater::install_dir}${minid_updater::application}",
    artifact_type => "jar",
  }
}