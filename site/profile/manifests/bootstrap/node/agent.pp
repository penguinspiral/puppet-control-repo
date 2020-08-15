class profile::bootstrap::node::agent() {
  
  # Puppet Agent daemon
  # Not automatically enabled during installation of `puppet` APT package
  file { '/etc/systemd/system/multi-user.target.wants/puppet.service':
    ensure => link,
    owner  => 'root',
    group  => 'root',
    target => '/lib/systemd/system/puppet.service',
  }

}
