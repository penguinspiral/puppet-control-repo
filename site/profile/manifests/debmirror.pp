class profile::debmirror(
  Boolean $local_mirror                  = false,
  Stdlib::Absolutepath $local_mirror_tar = '/dev/null',
  Stdlib::Absolutepath $mirror_path, 
  Integer[0,65533] $user                 = 0,
  Integer[0,65533] $group                = 0,
) {

  # VVV THIS NEEDS TO BE IN THE METAPROFILE VVV

  file { $mirror_path:
    ensure => directory,
  }

  # Copy seed repo 
  archive { $local_mirror_tar:
    ensure       => $local_mirror,
    extract      => true,
    extract_path => $mirror_path,
    creates      => "$mirror_path/200m.file",
    user         => $user,
    group        => $group,
  }

  # CONFIGURE PROFILE
}
