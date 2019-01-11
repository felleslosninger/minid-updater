# service.pp
class minid_updater::service inherits minid_updater {

  include difilib

  difilib::tomcat_service{ $minid_updater::application:
    context         => $minid_updater::context,
    tomcat_instance => $minid_updater::tomcat_instance
  }
}

