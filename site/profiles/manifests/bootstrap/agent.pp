# @summary
#   Populates the bootstrapped node's Puppet "role" as a local fact
#   Specifies the Puppet agent's targeted Puppetserver for obtaining its catalog
#   Configures the Puppet agent to run at startup via systemd
#
# @example
#   include profiles::bootstrap
#
# @param role
#   Specify the node's "role" (Roles & Profiles pattern)
#   Specified as a kernel command-line parameter and sourced via env var: FACTER_ROLE
#
# @param puppet_config
#   Specify the absolute path of the global Puppet configuration file
#
# @param puppetserver
#   Specify the hostname of the targeted Puppetserver
#
class profiles::bootstrap::agent (
  String[1]            $role          = $facts['role'],
  Stdlib::AbsolutePath $puppet_config = $settings::config,
  Stdlib::Host         $puppetserver  = 'localhost',
) {
  include profiles::apt

  facter::fact { 'role':
    value => $role,
  }

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
