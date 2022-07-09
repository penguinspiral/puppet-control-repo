# @summary
#  Manages Trivial File Transfer Protocol (TFTP) server configuration/behaviour
#  Extensively utilised by "traditional" (i.e. non-EFI HTTP booting) PXE environments
#  Predominantly a wrapper around the 'puppetlabs-tftp' Forge module
#
# @example
#   include profiles::tftp
#
# @param address
#  Specify the IPv4 address for the TFTP daemon to listen on
#  Defaults to 'localhost' for security sensibilities
#  Wrapper parameter: 'puppetlabs-tftp' module class parameter
#
# @param port
#  Specify the port for the TFTP daemon to bind against
#  Wrapper parameter: 'puppetlabs-tftp' module class parameter
#
# @param username
#  Specify the username for the TFTP daemon to run as
#  Wrapper parameter: 'puppetlabs-tftp' module class parameter
#
# @param managed_dirs
#  Specify the director[y|ies] for the TFTP daemon to export
#  Specified director[y|ies] are explicitly managed by 'profiles::tftp'
#  Limited to exactly one directory when using '--secure' option
#  Ref: man tftpd-hpa(8)
#
# @param external_dirs
#  Specify the director[y|ies] for the TFTP daemon to export
#  Specified director[y|ies] are not managed by 'profiles::tftp'
#  Limited to exactly one directory when using '--secure' option
#  Ref: man tftpd-hpa(8)
#
# @param options
#  Specify additional TFTP daemon runtime options
#  Ref: man tftpd-hpa(8)
#  Wrapper parameter: 'puppetlabs-tftp' module class parameter
#
class profiles::tftp (
  Stdlib::Host                $address        = 'localhost',
  Stdlib::Port                $port           = 69,
  String[1]                   $username       = 'tftp',
  Array[Stdlib::Absolutepath] $managed_dirs   = [],
  Array[Stdlib::Absolutepath] $external_dirs  = [],
  Array[String[1]]            $options        = [],
) {
  $duplicate_dirs = intersection($managed_dirs, $external_dirs)
  if !empty($duplicate_dirs) {
    fail("Duplicate directories detected: ${duplicate_dirs.join(', ')}")
  }

  file { $managed_dirs:
    ensure => directory,
    mode   => '0755',
    owner  => 'root',
    group  => 'nogroup',
  }

  class { 'tftp':
    address   => $address,
    port      => $port,
    username  => $username,
    directory => join($managed_dirs + $external_dirs, ' '),
    options   => join($options, ' '),
    inetd     => false,
  }
}
