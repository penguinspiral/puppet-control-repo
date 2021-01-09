# @summary
#   Manages Open Secure SHell (OpenSSH) Client & Server configuration
#   Responsible for configuration of ssh_config(5) and sshd_config(5) options
#   Predominantly a wrapper around the 'ghoneycutt-ssh' Forge module
#
# @example
#   include profiles::ssh
#
# @param service_ensure
#   Specify the OpenSSH server (sshd) service state
#   Wrapper parameter: 'ghoneycutt-ssh' module class parameter
#
# @param manage_sshd_config
#   Specify whether this module manages the OpenSSH server configuration
#
# @param manage_ssh_config
#   Specify whether this module manages the OpenSSH client configuration
#
# @param sshd_config_path
#   Specify the absolute path to the OpenSSH server configuration file
#   Wrapper parameter: 'ghoneycutt-ssh' module class parameter
#
# @param ssh_config_path
#   Specify the absolute path to the OpenSSH client configuration file
#   Wrapper parameter: 'ghoneycutt-ssh' module class parameter
#
# @param permit_root_login
#   Specify the manner in which the 'root' user can access the host
#   Ref: man sshd_config(5) ~ 'PermitRootLogin'
#   Wrapper parameter: 'ghoneycutt-ssh' module class parameter
#
# @param sshd_password_authentication
#   Specify whether password authentication is allowed
#   Wrapper parameter: 'ghoneycutt-ssh' module class parameter
#
# @param sshd_pubkeyauthentication
#   Specify whether public key authentication is allowed
#   Wrapper parameter: 'ghoneycutt-ssh' module class parameter
#
# @param keys
#   Hash of 'ssh_authorized_key' defining $USER/.ssh/authorized_keys
#   Wrapper parameter: 'ghoneycutt-ssh' module class parameter
#
class profiles::ssh(
  Stdlib::Ensure::Service                                       $service_ensure               = 'running',
  Boolean                                                       $manage_sshd_config           = true,
  Boolean                                                       $manage_ssh_config            = false,
  Stdlib::Absolutepath                                          $sshd_config_path             = '/etc/ssh/sshd_config',
  Stdlib::Absolutepath                                          $ssh_config_path              = '/etc/ssh/ssh_config',
  Enum['yes', 'no', 'without-password', 'forced-commands-only'] $permit_root_login            = 'no',
  Enum['yes', 'no']                                             $sshd_password_authentication = 'no',
  Enum['yes', 'no']                                             $sshd_pubkeyauthentication    = 'yes',
  Hash[String, Hash]                                            $keys                         = {},
){
  if (empty($keys)) and ($sshd_password_authentication == 'no') {
    fail('No SSH public key referenced and password authentication is disabled!')
  }

  # Facilitate client/server only management by file substitution
  $sshd_config_path_real = $manage_sshd_config ? {
    true  => $sshd_config_path,
    false => "${sshd_config_path}.fake",
  }

  $ssh_config_path_real = $manage_ssh_config ? {
    true  => $ssh_config_path,
    false => "${ssh_config_path}.fake",
  }

  class { 'ssh':
    service_ensure               => $service_ensure,
    sshd_config_path             => $sshd_config_path_real,
    ssh_config_path              => $ssh_config_path_real,
    hiera_merge                  => false,
    permit_root_login            => $permit_root_login,
    sshd_password_authentication => $sshd_password_authentication,
    sshd_pubkeyauthentication    => $sshd_pubkeyauthentication,
    keys                         => $keys,
  }
}
