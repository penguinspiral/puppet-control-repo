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
class profiles::bootstrap::server (
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

    '/etc/systemd/system/multi-user.target.wants/puppetserver.service':
      ensure => link,
      target => '/lib/systemd/system/puppetserver.service',
      ;

    '/etc/systemd/system/puppetserver.service.d':
      ensure => directory,
      ;

    # Puppetserver must start before Puppet agent
    '/etc/systemd/system/puppetserver.service.d/override.conf':
      ensure  => file,
      content => "[Unit]\nBefore=puppet.service",
      ;
  }

  hocon_setting { 'puppetserver_webserver_host':
    ensure  => present,
    path    => $puppetserver_web_config,
    setting => 'webserver.ssl-host',
    value   => 'localhost',
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

    'puppetserver_dns_alt_names':
      section => 'server',
      setting => 'dns_alt_names',
      value   => 'localhost',
      ;
  }
}
