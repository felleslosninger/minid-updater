#deploy.pp

class minid_updater::deploy inherits minid_updater {

  include 'difilib'

  difilib::webapp_deploy { $minid_updater::application:
    package         => 'no.idporten',
    artifact        => 'minid-web-updater',
    context         => $minid_updater::context,
    tomcat_instance => $minid_updater::tomcat_instance
  }
}