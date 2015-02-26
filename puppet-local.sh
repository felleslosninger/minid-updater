export PL_BASEDIR="/c/Program Files (x86)/Puppet Labs/Puppet/"
export FACTER_env_windows_installdir=$PL_BASEDIR

export PUPPET_DIR=$PL_BASEDIR\puppet
export FACTER_DIR=$PL_BASEDIR\facter
export HIERA_DIR=$PL_BASEDIR\hiera

export PATH=$PUPPET_DIR/bin:$FACTER_DIR/bin:$HIERA_DIR/bin:$PL_BASEDIR/bin:$PL_BASEDIR/sys/ruby/bin:$PL_BASEDIR/sys/tools/bin:$PATH
export RUBYLIB=$PUPPET_DIR/lib:$FACTER_DIR/lib:$HIERA_DIR/lib:$RUBYLIB
export RUBYOPT=rubygems
ruby -S -- "$PUPPET_DIR\bin\puppet" apply --modulepath="..\..\vagrant\puppet\modules" -e "include minid-updater::config"