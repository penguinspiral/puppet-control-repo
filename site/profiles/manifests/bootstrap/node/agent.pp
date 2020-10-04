# @summary
#   Specifies the Puppet agent's targeted Puppet server for obtain its catalog
#   Configures the Puppet agent to run at startup via systemd
#
# @example
#   include profiles::bootstrap
#
# @param puppet_server
#   Specifies the hostname of the Puppet server
#
class profiles::bootstrap::node::agent(
  Stdlib::Host $puppet_server = 'localhost',
) {

  file { '/etc/systemd/system/multi-user.target.wants/puppet.service':
    ensure => link,
    owner  => 'root',
    group  => 'root',
    target => '/lib/systemd/system/puppet.service',
  }

  ini_setting { 'puppet_server_host':
    ensure            => present,
    path              => '/etc/puppet/puppet.conf',
    key_val_separator => '=',
    section           => 'main',
    setting           => 'server',
    value             => $puppet_server,
  }

}
