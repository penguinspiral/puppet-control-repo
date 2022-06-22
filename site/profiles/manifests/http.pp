# @summary
#   Manages Apache HTTP server configuration/behaviour
#   Responsible for virtual hosts, Apache modules, load balancing, etc
#   Predominantly a wrapper around the 'puppetlabs-apache' Forge module
#
# @see
#   man apache2(8)
#
# @example
#   include profiles::http
#
# @param service_enable
#   Specify whether apache service starts during boot
#   Wrapper parameter: 'puppetlabs-apache' module class parameter
#
# @param service_ensure
#   Specify the apache service state
#   Wrapper parameter: 'puppetlabs-apache' module class parameter
#
# @param default_vhost
#   Specify whether to enable the 'puppetlabs-apache' default vhost configuration
#   Apache HTTP server requires at least one virtual host to start
#   Wrapper parameter: 'puppetlabs-apache' module class parameter
#
# @param default_ssl_vhost
#   Specify whether to enable the 'puppetlabs-apache' default SSL vhost configuration
#   Apache HTTP server requires at least one virtual host to start
#   Wrapper parameter: 'puppetlabs-apache' module class parameter
#
# @param root_directory_secured
#   Specify whether the default access policy is denied for all resources
#   Enablement requires explicit rules for allowing access to additional resources
#   Wrapper parameter: 'puppetlabs-apache' module class parameter
#
# @param vhosts
#   Specify Apache virtual host(s)
#   Facilitates multiple virtual hosts instantiations via Hiera data definitions
#   Ref: https://github.com/puppetlabs/puppetlabs-apache/blob/main/manifests/vhost.pp
#   Wrapper parameter: 'puppetlabs-apache' ::vhosts subclass parameter
#
class profiles::http (
  Boolean                 $service_enable         = false,
  Stdlib::Ensure::Service $service_ensure         = 'stopped',
  Boolean                 $default_vhost          = false,
  Boolean                 $default_ssl_vhost      = false,
  Boolean                 $root_directory_secured = true,
  Hash                    $vhosts                 = {},
) {
  class { 'apache':
    service_enable         => $service_enable,
    service_ensure         => $service_ensure,
    default_vhost          => $default_vhost,
    default_ssl_vhost      => $default_ssl_vhost,
    root_directory_secured => $root_directory_secured,
  }

  class { 'apache::vhosts':
    vhosts => $vhosts,
  }
}
