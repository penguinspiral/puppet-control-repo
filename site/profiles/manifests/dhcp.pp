# @summary
#   Manages isc-dhcp-server configuration/behaviour
#   Responsible for subnet allocation, host reservations, (i)PXE URIs, etc
#   Predominantly a wrapper around the 'puppet-dhcp' Forge module
#
# @see
#   https://tools.ietf.org/html/rfc2132
#   https://tools.ietf.org/html/rfc3397
#
# @example
#   include profiles::dhcp
#
# @param service_ensure
#   Specify whether the isc-dhcp-server service state
#   Wrapper parameter: 'puppet-dhcp' module class parameter
#
# @param interfaces
#   Specify interface(s) for isc-dhcp-server to listen on (UDP/67)
#   Wrapper parameter: 'puppet-dhcp' module class parameter
#
# @param dnsdomain
#   Specify "global" DNS domains (Option 15)
#   First DNS domain element is assigned the 'domain-name' option
#   Subsequent DNS domain element(s) are utilised with DDNS zones
#   Wrapper parameter: 'puppet-dhcp' module class parameter
#
# @param nameservers
#   Specify "global" DNS nameserver(s) (Option 6)
#   Wrapper parameter: 'puppet-dhcp' module class parameter
#
# @param dnssearchdomains
#   Specify "global" DNS "search" domains (Option 119)
#   Wrapper parameter: 'puppet-dhcp' module class parameter
#
# @param ntpservers
#   Specify Network Time Protocol (NTP) server(s) (Option 4)
#   Wrapper parameter: 'puppet-dhcp' module class parameter
#
# @param pools
#   Specify DHCP pool(s)/zone(s) attributes (e.g. subnets, gateway, etc)
#   Wrapper parameter: 'puppet-dhcp' module class parameter
#
class profiles::dhcp(
  Stdlib::Ensure::Service                          $service_ensure   = 'stopped',
  Array[String[1]]                                 $interfaces       = [],
  Array[String[1]]                                 $dnsdomain        = [],
  Array[Stdlib::IP::Address::V4]                   $nameservers      = [],
  Array[String[1]]                                 $dnssearchdomains = [],
  Array[Variant[Stdlib::Fqdn,Stdlib::IP::Address]] $ntpservers       = [],
  Hash[String, Hash]                               $pools            = {},
) {
  class { 'dhcp':
    service_ensure   => $service_ensure,
    interfaces       => $interfaces,
    dnsdomain        => $dnsdomain,
    nameservers      => $nameservers,
    dnssearchdomains => $dnssearchdomains,
    ntpservers       => $ntpservers,
    pools            => $pools,
  }
}
