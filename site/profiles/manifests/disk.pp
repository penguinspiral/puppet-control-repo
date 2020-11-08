# @summary
#   Manages the node's "external" block devices (i.e. non-root)
#   Performs filesystem creation and manages mount behaviours
#
# @example
#   include profiles::disk
#
# @param filesystems
#   Format target block device(s) with specified filesystem
#   Arbritrary filesystem options during initial creation/format can be specified
#   Wrapper parameter: 'puppetlabs-lvm' module filesystem custom "type"
#   Title: udev disk by-id value (recommended)
#
# @param mounts
#  Mount options of the target block device(s)
#  Title: udev disk by-uuid (filesystem)
#
class profiles::disk(
  Hash $filesystems = {},
  Hash $mounts      = {},
) {
  ensure_resources('filesystem', $filesystems)
  ensure_resources('mount', $mounts)
}
