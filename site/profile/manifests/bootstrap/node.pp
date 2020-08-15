# Bootstrapping Serverless Puppet
#
# Rationale:
#   We do *not* have a functioning systemd environment
#   during the preseed installation; consequently the
#   `systemd` Puppet module cannot be used
#
class profile::bootstrap::node(
  Boolean $serverless = true,
){
  include profile::bootstrap::node::agent
  if ($serverless) {
    include profile::bootstrap::node::master
  }
}
