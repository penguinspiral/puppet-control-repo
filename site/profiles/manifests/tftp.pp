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
# @param directory
#  Specify the director[y|ies] for the TFTP daemon to export
#  Limited to exactly one directory when using '--secure' option
#  Ref: man tftpd-hpa(8)
#  Wrapper parameter: 'puppetlabs-tftp' module class parameter
#
# @param options
#  Specify additional TFTP daemon runtime options
#  Ref: man tftpd-hpa(8)
#  Wrapper parameter: 'puppetlabs-tftp' module class parameter
#
class profiles::tftp (
  Stdlib::Host                $address   = 'localhost',
  Stdlib::Port                $port      = 69,
  String[1]                   $username  = 'tftp',
  Array[Stdlib::Absolutepath] $directory = [],
  Array[String[1]]            $options   = [],
) {
  class { 'tftp':
    address   => $address,
    port      => $port,
    username  => $username,
    directory => join($directory, ' '),
    options   => join($options, ' '),
    inetd     => false,
  }
}
