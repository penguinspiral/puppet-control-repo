# @summary
#   Specifies the Puppet agent's targeted Puppetserver for obtain its catalog
#   Configures the Puppet agent to run at startup via systemd
#
# @example
#   include profiles::bootstrap
#
# @param puppet_config
#   Specify the absolute path to the global Puppet configuration file
#
# @param puppetserver
#   Specify the hostname of the targeted Puppetserver
#
class profiles::bootstrap::node::agent(
  Stdlib::AbsolutePath $puppet_config = $settings::config,
  Stdlib::Host         $puppetserver = 'localhost',
) {

  file { '/etc/systemd/system/multi-user.target.wants/puppet.service':
    ensure => link,
    owner  => 'root',
    group  => 'root',
    target => '/lib/systemd/system/puppet.service',
  }

  ini_setting { 'puppetserver_host':
    ensure            => present,
    path              => $puppet_config,
    key_val_separator => '=',
    section           => 'main',
    setting           => 'server',
    value             => $puppetserver,
  }

}
