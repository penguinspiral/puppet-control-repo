# @summary
#   Manages ISC BIND DNS server (bind9) configuration/behaviour
#   Responsible for zone allocation, recursion & forwarding, rndc keys, etc.
#   Predominantly a wrapper around the 'theforeman-dns' Forge module
#
# @example
#   include profiles::dns
#
# @param service_ensure
#   Specify the bind9 service state
#   Wrapper parameter: 'theforeman-dns' module class parameter
#
# @param config_check
#   Specify whether DNS server configuration files are validated
#   Wrapper parameter: 'theforeman-dns' module class parameter
#
# @param recursion
#   Specify whether the DNS server operates in "Recursive Mode"
#   Ref: "Recursive Mode" definition (https://tools.ietf.org/html/rfc7719)
#   Wrapper parameter: 'theforeman-dns' module class parameter
#
# @param allow_recursion
#   Specify the *global* "address(es)" allowed to perform "recursive" queries
#   Wrapper parameter: 'theforeman-dns' module class parameter
#
# @param allow_query
#   Specify the *global* "address(es)" allowed to perform managed zone queries
#   Wrapper parameter: 'theforeman-dns' module class parameter
#
# @param forward
#   Specify the "type" of DNS query forwarding to be performed
#   Ref: "Forwarders" definition (https://tools.ietf.org/html/rfc7719)
#   Wrapper parameter: 'theforeman-dns' module class parameter
#
# @param forwarders
#   Specify the DNS server(s) IPs that will answer forwarded DNS queries
#   Leveraging Stdlib IPv4 type to adhere to 'bind9' compatibility
#   Wrapper parameter: 'theforeman-dns' module class parameter
#
# @param acls
#   Specify Access Control List(s) (ACL) statement(s) in 'named.conf'
#   Ref: "acls" section (https://bind9.readthedocs.io/en/latest/reference.html)
#   Wrapper parameter: 'theforeman-dns' module class parameter
#
# @param keys
#   Specify local Remote Name Daemon Control (RNDC) key(s)
#   Wrapper parameter: 'theforeman-dns' module class parameter
#
# @param enable_views
#   Specify support for "Views", removes global zone configuration
#   Ref: "Views" definition (https://tools.ietf.org/html/rfc7719#section-5)
#   Wrapper parameter: 'theforeman-dns' module class parameter
#
# @param views
#   Specify managed DNS "view(s)" depending on query attributes/characteristics
#   Facilitates multiple "view" instantiations via Hash data resource definitions
#
# @param zones
#   Specify authoritative/managed DNS "zone(s)"
#   Ref: "Zones" definition (https://tools.ietf.org/html/rfc7719#section-6)
#   Wrapper parameter: 'theforeman-dns' module class parameter
#
# @param additional_options
#   Specify additional generic/free-form options appended to 'options.conf'
#   Wrapper parameter: 'theforeman-dns' module class parameter
#
class profiles::dns (
  Stdlib::Ensure::Service         $service_ensure     = 'stopped',
  Boolean                         $config_check       = true,
  Enum['yes', 'no']               $recursion          = 'no',
  Array[String]                   $allow_recursion    = ['none'],
  Array[String]                   $allow_query        = ['none'],
  Optional[Enum['only', 'first']] $forward            = undef,
  Array[Stdlib::IP::Address::V4]  $forwarders         = [],
  Hash[String, Array[String]]     $acls               = {},
  Hash[String, Hash]              $keys               = {},
  Boolean                         $enable_views       = false,
  Hash[String, Hash]              $views              = {},
  Hash[String, Hash]              $zones              = {},
  Hash[String, Data]              $additional_options = {},
) {
  class { 'dns':
    service_ensure     => $service_ensure,
    config_check       => $config_check,
    recursion          => $recursion,
    allow_recursion    => $allow_recursion,
    allow_query        => $allow_query,
    forward            => $forward,
    forwarders         => $forwarders,
    acls               => $acls,
    keys               => $keys,
    enable_views       => $enable_views,
    zones              => $zones,
    additional_options => $additional_options,
  }

  create_resources('dns::view', $views)
}
