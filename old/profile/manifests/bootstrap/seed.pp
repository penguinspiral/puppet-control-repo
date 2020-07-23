# Phases of bootstrap:
# - "Seed":
#   1. Define 'mnt-mirror.mount' systemd unit for USB mirror
#   2. Define '${release}-local-mirror.source' in APT sources.d/ for USB
#   3. Define 'puppet-master' systemd service unit file
#   4. Define 'puppet-master' systemd timer unit file
class profile::bootstrap::seed (
  Stdlib::Absolutepath $mount_device,
  Stdlib::Absolutepath $mount_path,
  Hash $local_mirrors,
) {

  include apt
  include stdlib
  include systemd

  # SHOULD WE USE `mount` RESOURCE TYPE FOR CDROM/USB ISO9660
  # INSTEAD OF MANUALLY DROPPING SYSTEMD SERVICE FILES?!
  # NO! BOOTSTRAP SHOULD DO _THE BARE MINIMUM_ PRACTICALLY A `node.pp` instance...

  $mnt_mirror_content = epp("${module_name}/bootstrap/seed/mnt-mirror.mount.epp", {
    'mount_device' => $mount_device,
    'mount_path'   => $mount_path,
  })

  systemd::unit_file { 'mnt-mirror.mount':
    content => $mnt_mirror_content,
    enable  => true,
  }

  # https://forge.puppet.com/puppetlabs/apt#configure-apt-from-hiera
  # INSTEAD WE WANT TO FORCE ALL VALUE INGESTION INTO PROFILE -- NOT COMPONENT MODULE DIRECTLY
  # FACILITATE MULTIPLE LOCAL MIRRORS BEING DEFINED :D
  ensure_resources(apt::source, $local_mirrors)

  # apt::source { 'local_mirror':
  #   * => $apt_mirror,
  # }
  
}

