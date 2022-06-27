# @summary
#   Manages isc-dhcp-server configuration/behaviour
#   Responsible for subnet allocation, host reservations, (i)PXE URIs, etc
#   Predominantly a wrapper around the 'puppet-dhcp' Forge module
#
# @see
#   https://tools.ietf.org/html/rfc2132
#   https://tools.ietf.org/html/rfc3397
#   man dhcpd.conf(5)
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
#   Specify "global" DNS nameserver(s) IPv4 addresses (Option 6)
#   First DNS nameserver is specified as "primary" for all DDNS zones
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
# @param globaloptions
#   Specify arbritrary, globally scoped ISC DHCP option(s)
#   Wrapper parameter: 'puppet-dhcp' module class parameter
#
# @param dnsupdatekey
#   Specify a Remote Name Daemon Control (RNDC) key file for Dynamic DNS (DDNS)
#   DDNS is disabled unless the absolute path for a valid key is set
#   Wrapper parameter: 'puppet-dhcp' module class parameter
#
# @param dnskeyname
#   Specify the RNDC key name for reference in DDNS zone definitions
#   Wrapper parameter: 'puppet-dhcp' module class parameter
#
# @param ddns_client_updates
#   Specify whether perform DDNS updates for clients on their behalf
#   Wrapper parameter: 'puppet-dhcp' module class parameter
#
# @param ddns_update_style
#   Specify DDNS update "style"; communication method between DHCP & DNS server
#   Wrapper parameter: 'puppet-dhcp' module class parameter
#
# @param ddns_update_static
#   Specify whether to perform DNS updates for assigned "static" clients
#   Wrapper parameter: 'puppet-dhcp' module class parameter
#
# @param ddns_update_optimize
#   Specify whether to perform DDNS updates "on-change" or "always"
#   Wrapper parameter: 'puppet-dhcp' module class parameter
#
# @param pools
#   Specify DHCP pool(s)/zone(s) attributes (e.g. subnets, gateway, etc)
#   Wrapper parameter: 'puppet-dhcp' module class parameter
#
# @param hosts
#   Specify DHCP host(s) reservations & options
#   Wrapper parameter: 'puppet-dhcp' module class parameter
#
# @param pxeserver
#   Specify Trivial File Transfer Protocol (TFTP) server (Option 66)
#   Utilises iPXE implementation of PXE for PCBIOS & UEFI support
#   Ref: https://ipxe.org/
#
# @param pxefilename
#   Specify the chainloaded "Bootfile" to be loaded by PXE clients (Option 67)
#   iPXE "Bootfile" script scoped to absolute path (TFTP) or HTTP(S) URL (HTTP)
#
class profiles::dhcp (
  Stdlib::Ensure::Service                                  $service_ensure       = 'stopped',
  Array[String[1]]                                         $interfaces           = [],
  Array[String[1]]                                         $dnsdomain            = [],
  Array[Stdlib::IP::Address::V4]                           $nameservers          = [],
  Array[String[1]]                                         $dnssearchdomains     = [],
  Array[Variant[Stdlib::Fqdn, Stdlib::IP::Address]]        $ntpservers           = [],
  Optional[Variant[String,Array[String[1]]]]               $globaloptions        = undef,
  Optional[Stdlib::Absolutepath]                           $dnsupdatekey         = undef,
  String[1]                                                $dnskeyname           = 'rndc-key',
  Enum['allow', 'deny']                                    $ddns_client_updates  = 'deny',
  Enum['ad-hoc', 'interim', 'standard', 'none']            $ddns_update_style    = 'standard',
  Enum['on', 'off']                                        $ddns_update_static   = 'off',
  Enum['on', 'off']                                        $ddns_update_optimize = 'on',
  Hash[String, Hash]                                       $pools                = {},
  Hash[String[1], Hash]                                    $hosts                = {},
  Optional[Stdlib::Host]                                   $pxeserver            = undef,
  Optional[Variant[Stdlib::Absolutepath, Stdlib::HTTPUrl]] $pxefilename          = undef,
) {
  if (!$pxeserver != !$pxefilename) {
    fail('$pxeserver and $pxefilename are required when enabling PXE')
  }

  $dhcp_conf_pxe_content = epp('profiles/dhcp/dhcpd.pxe.epp', {
      'pxeserver'   => $pxeserver,
      'pxefilename' => $pxefilename,
  })

  class { 'dhcp':
    service_ensure       => $service_ensure,
    interfaces           => $interfaces,
    dnsdomain            => $dnsdomain,
    nameservers          => $nameservers,
    dnssearchdomains     => $dnssearchdomains,
    ntpservers           => $ntpservers,
    globaloptions        => $globaloptions,
    dnsupdatekey         => $dnsupdatekey,
    dnskeyname           => $dnskeyname,
    ddns_client_updates  => $ddns_client_updates,
    ddns_update_style    => $ddns_update_style,
    ddns_update_static   => $ddns_update_static,
    ddns_update_optimize => $ddns_update_optimize,
    pools                => $pools,
    hosts                => $hosts,
    dhcp_conf_pxe        => $dhcp_conf_pxe_content,
  }
}
