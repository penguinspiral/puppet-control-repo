class role::seed {
  include profile::puppet
  include profile::disk
  include profile::apt
  include profile::webserver::apache

  # Class['profile::disk']
  # -> Class['profile::apt']
  # -> Class['profile::webserver::apache']
}
