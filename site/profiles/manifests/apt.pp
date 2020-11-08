# @summary
#   Manages Debian's Advanced Package Tool (APT) configuration/behaviour
#   Responsible for repository sources, package pins, repository GPG keys, etc
#   Predominantly a wrapper around the 'puppetlabs-apt' Forge module
#
# @example
#   include profiles::apt
#
# @param purge
#   Specify APT repository configuration file(s) to empty contents
#   Wrapper parameter: 'puppetlabs-apt' module class parameter
#
# @param sources
#   Specify APT respository URI and corresponding settings (e.g. repos)
#   Wrapper parameter: 'puppetlabs-apt' module class parameter
#
class profiles::apt(
  Hash $purge   = {},
  Hash $sources = {},
) {
  class { 'apt':
    purge   => $purge,
    sources => $sources,
  }
}
