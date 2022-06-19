# @summary
#  Manages the node's network interface(s), static route(s), rule(s)
#  Leverages the '/etc/network/interfaces' consumed by `ifup/ifdown`
#
# @example
#   include profiles::network
#
# @param interfaces
#   Specifies the network interface(s) to manage
#
class profiles::network (
  Hash $interfaces = {},
) {
  class { 'network':
    interfaces_hash => $interfaces,
  }
}
