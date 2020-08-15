# Configure Serverless Puppet
#
# - "Node":
#   1. Define 'puppet-master' systemd service unit file
#   2. Define 'puppet-master' systemd timer unit file
#
class profile::puppet() {

  include systemd

  # Create service & timer unit file pair
  systemd::timer { 'puppet-master.timer':
    timer_source   => "puppet:///modules/${module_name}/puppet/puppet-master.timer",
    service_source => "puppet:///modules/${module_name}/puppet/puppet-master.service",
    active         => true,
    enable         => true,
  }

}
