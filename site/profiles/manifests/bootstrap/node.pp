# @summary 
#   Specifies how a targeted node's Puppet agent obtains its catalog
#   Supports both a client-only and standalone (a.k.a. serverless) configuration
#
# @example
#   include profiles::bootstrap
#
# @param serverless
#   Installs and configures a locally hosted Puppetserver for catalog generation
#
class profiles::bootstrap::node(
  Boolean $serverless = true,
){
  include profiles::bootstrap::node::agent
  if ($serverless) {
    include profiles::bootstrap::node::server
  }
}
