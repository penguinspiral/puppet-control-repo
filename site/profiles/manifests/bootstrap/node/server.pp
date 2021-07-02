# @summary
#   Configures a Puppet master to support a serverless Puppet deployment
#   Binds the Puppet master daemon to localhost for isolated catalog generation
#
# @example
#   include profiles::bootstrap
#
class profiles::bootstrap::node::master() {

  file {
    default:
      owner => 'root',
      group => 'root',
    ;

    '/etc/systemd/system/multi-user.target.wants/puppet-master.service':
      ensure => link,
      target => '/lib/systemd/system/puppet-master.service',
    ;

    '/etc/systemd/system/puppet-master.service.d':
      ensure => directory,
    ;

    # Puppet master must start before Puppet agent
    '/etc/systemd/system/puppet-master.service.d/override.conf':
      ensure  => file,
      content => "[Unit]\nBefore=puppet.service",
    ;
  }

  ini_setting {
    default:
      ensure            => present,
      path              => '/etc/puppet/puppet.conf',
      key_val_separator => '=',
    ;

    'r10k_prerun':
      section => 'main',
      setting => 'prerun_command',
      value   => '/usr/bin/r10k deploy environment --verbose --puppetfile --config /etc/puppet/r10k/r10k.yaml',
    ;

    'puppet_master_dns_cert':
      section => 'master',
      setting => 'dns_alt_names',
      value   => 'localhost',
    ;

    'puppet_master_localhost':
      section => 'master',
      setting => 'bindaddress',
      value   => '127.0.0.1',
    ;
  }

}
