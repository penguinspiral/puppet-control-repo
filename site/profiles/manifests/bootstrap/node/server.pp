# @summary
#   Configures a Puppetserver to support a "serverless" Puppet deployment
#   Binds the Puppetserver daemon to localhost for isolated catalog generation
#   Automatically generated CA environment includes "localhost" as a X509v3 SAN
#
# @example
#   include profiles::bootstrap
#
# @param puppet_config
#   Specify the absolute path to the global Puppet configuration file
#
# @param puppetserver_web_config
#   Specify the absolute path to the Puppetserver Webserver configuration file
#
# @param r10k_binary
#   Specify the absolute path to the r10k binary
#
# @param r10k_config
#   Specify the absolute path to the r10k configuration file
#   Tracked file within the penguinspiral/puppet-r10k Git repository
#
class profiles::bootstrap::node::server(
  Stdlib::AbsolutePath $puppet_config           = $settings::config,
  Stdlib::AbsolutePath $puppetserver_web_config = '/etc/puppetlabs/puppetserver/conf.d/webserver.conf',
  Stdlib::AbsolutePath $r10k_binary             = '/usr/bin/r10k',
  Stdlib::AbsolutePath $r10k_config             = '/etc/puppetlabs/r10k/r10k.yaml',
) {

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
      path              => $puppet_config,
      key_val_separator => '=',
    ;

    'r10k_prerun_command':
      section => 'main',
      setting => 'prerun_command',
      value   => "${r10k_binary} deploy environment --verbose --puppetfile --config ${r10k_config}",
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
