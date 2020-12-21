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
  Enum['yes', 'no', 'without-password', 'forced-commands-only'] $permit_root_login            = 'no',
  Enum['yes', 'no']                                             $sshd_password_authentication = 'no',
  Enum['yes', 'no']                                             $sshd_pubkeyauthentication    = 'yes',
  Hash[String, Hash]                                            $keys                         = {},
){
  if (empty($keys)) and ($sshd_password_authentication == 'no') {
    fail('No SSH public key referenced and password authentication is disabled!')
  }

  class { 'ssh':
    service_ensure               => $service_ensure,
    hiera_merge                  => false,
    permit_root_login            => $permit_root_login,
    sshd_password_authentication => $sshd_password_authentication,
    sshd_pubkeyauthentication    => $sshd_pubkeyauthentication,
    keys                         => $keys,
  }
}
