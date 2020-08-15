# Bootstrapping a serverless Puppet deployment
class profile::bootstrap::node::master() {

  # TEST HERE
  # TEST 2!

  # Puppet Master daemon
  # Automatically enabled by `puppet-master` APT package
  # Listed explicitly to adhere to consistency with the Puppet agent module
  # file { '/etc/systemd/system/multi-user.target.wants/puppet-master.service':
  #   ensure => link,
  #   owner  => 'root',
  #   group  => 'root',
  #   target => '/lib/systemd/system/puppet-master.service',
  # }

  # Puppet Agent default: puppet:8140
  # Overrides local DNS to ensure self reference
  host { 'puppet':
    ensure  => present,
    ip      => '127.0.0.1',
    comment => 'Serverless Puppet',
  }

  # Ensure ordering
  file {
    default:
      owner => 'root',
      group => 'root',
    ;
    '/etc/systemd/system/puppet-master.service.d':
      ensure => directory,
    ;
    '/etc/systemd/system/puppet-master.service.d/override.conf':
      ensure  => file,
      content => "[Unit]\nBefore=puppet.service"  
  }

  # Ensure r10k is ran
  ini_setting { 
    default:
      ensure            => present,
      path              => '/etc/puppet/puppet.conf',
      key_val_separator => '=',
    ;
    'r10k_first_run':
      section           => 'main',
      setting           => 'prerun_command',
      value             => '/usr/bin/r10k deploy environment --verbose --puppetfile --config /etc/puppet/r10k/r10k.yaml',
    ;
    'puppet_master_localhost':
      section           => 'master',
      setting           => 'bindaddress',
      value             => '127.0.0.1',
    }
}
