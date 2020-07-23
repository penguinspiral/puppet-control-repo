# First Boot phases
#
# Rationale:
#   We do *not* have a functioning systemd environment
#   during the preseed installation; the `systemd` Puppet
#   module cannot be used at this time
#
# - "All":
#   1. Define 'puppet-firstboot' systemd service file
#   2. Enable 'puppet-firstboot' systemd service file 'multi-user.target'
#   3. Runs Puppet at startup enabling systemd
#
class profile::bootstrap::firstboot {

  file {
    default:
      owner => 'root',
      group => 'root',
    ;
    '/etc/systemd/system/puppet-firstboot.service':
      ensure => present,
      source => "puppet:///modules/${module_name}/bootstrap/firstboot/puppet-firstboot.service",
      mode   => "0644"
    ;
    '/etc/systemd/system/multi-user.target.wants/puppet-firstboot.service':
      ensure => link,
      target => '/etc/systemd/system/puppet-firstboot.service',
  }

}
