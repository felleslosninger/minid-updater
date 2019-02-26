# service.pp
class minid_updater::service inherits minid_updater {


  include platform

  if ($platform::deploy_spring_boot) {
    service { $minid_updater::service_name:
      ensure => running,
      enable => true,
    }
  }
}
