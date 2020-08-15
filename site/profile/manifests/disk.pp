class profile::disk(
  Hash $fs          = {},
  Hash $mountpoints = {},
  Hash $mounts      = {},
) {

  ensure_resources('filesystem', $fs)
  ensure_resources('file', $mountpoints, {'ensure' => 'directory'})
  ensure_resources('mount', $mounts)

}
