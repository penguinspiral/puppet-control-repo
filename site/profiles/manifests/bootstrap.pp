# @summary
#   Performs minimal alteration required for a full Puppet run at first boot
#   This profile operates within a "limited" Debian Preseed chrooted environment
#   Consequently extending this profile and its subclasses is discouraged
#
# @example
#   include profiles::bootstrap
#
# @param seed
#   Specifies additional bootstrapping configuration for the given "seed" node
#
class profiles::bootstrap(
  Boolean $seed = false,
) {
  include profiles::bootstrap::node
  if ($seed) {
    include profiles::bootstrap::seed
  }
}
