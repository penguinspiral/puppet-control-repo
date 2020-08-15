# Basically a wrapper for extending APT down the line...
class profile::apt(
  Hash $purge   = {},
  Hash $sources = {},
  Hash $keys    = {},
  Hash $pins    = {},
) {

  class { 'apt': 
    purge   => $purge,
    sources => $sources,
    keys    => $keys,
    pins    => $pins,
  }

  # ensure_resources('apt::source', $sources)
  # ensure_resources('apt::key',    $keys)
  # ensure_resources('apt::pin',    $pins)

  # Race conditions!?
  # Exec['apt_update']
}
