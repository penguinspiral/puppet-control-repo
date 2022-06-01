# @summary
#   Performs minimal alteration required for a full Puppet run at first boot
#   This profile operates within a "limited" Debian Preseed chrooted environment
#   Consequently extending this profile and its subclasses is discouraged
#
# @example
#   include profiles::bootstrap
#
# @param serverless
#   Installs and configures a locally hosted Puppetserver for catalog generation
#
class profiles::bootstrap(
  Boolean $serverless = true,
) {
  include profiles::bootstrap::agent
  if ($serverless) {
    include profiles::bootstrap::server
  }
}
