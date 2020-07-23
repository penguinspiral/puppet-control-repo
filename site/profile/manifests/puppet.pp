# Configure Serverless Puppet
#
# - "Node":
#   1. Define 'puppet-master' systemd service unit file
#   2. Define 'puppet-master' systemd timer unit file
#
class profile::puppet {

  include systemd

  systemd::unit_file {
    default:
      enable => true,
    ;
    'puppet-master.service':
      source => "puppet:///modules/${module_name}/puppet/puppet-master.service",
    ;
    'puppet-master.timer':
      source => "puppet:///modules/${module_name}/puppet/puppet-master.timer",
      active => true,
  }

}

