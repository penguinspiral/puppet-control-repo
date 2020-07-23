# Bootstrapping Serverless Puppet
#
# Rationale:
#   We do *not* have a functioning systemd environment
#   during the preseed installation; consequently the 
#   `systemd` Puppet module cannot be used 
#
# - "All":
#   1. Define 'puppet-firstboot' systemd service file
#   2. Enable 'puppet-firstboot' systemd service file 'multi-user.target'
#   3. Runs Puppet at startup enabling systemd
#
class profile::bootstrap {

  file {
    default:
      owner => 'root',
      group => 'root',
    ;
    '/etc/systemd/system/puppet-bootstrap.service':
      ensure => present,
      source => "puppet:///modules/${module_name}/bootstrap/puppet-bootstrap.service",
      mode   => "0644",
    ;
    '/etc/systemd/system/multi-user.target.wants/puppet-bootstrap.service':
      ensure => link,
      target => '/etc/systemd/system/puppet-bootstrap.service',
  }

}
