# Bootstrap phases
#
# - "Node":
#   1. Define 'puppet-master' systemd service unit file
#   2. Define 'puppet-master' systemd timer unit file
#
class profile::bootstrap::node {

  include systemd

  systemd::unit_file {
    default:
      enable => true,
    ;
    'puppet-master.service':
      source => "puppet:///modules/${module_name}/bootstrap/node/puppet-master.service",
      active => false,
    ;
    'puppet-master.timer':
      source => "puppet:///modules/${module_name}/bootstrap/node/puppet-master.timer",
  }

}
