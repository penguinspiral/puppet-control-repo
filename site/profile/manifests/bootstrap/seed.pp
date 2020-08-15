# Additional work required by the "seed" node
class profile::bootstrap::seed(
  Array[String] $facter_facts_dir = ['/etc/facter/', '/etc/facter/facts.d/'],
  Hash $facter_seed_facts         = { role => 'seed' },
) {

  # Initialise APT early
  include profile::apt

  file { $facter_facts_dir:
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '755',
  }

  file { '/etc/facter/facts.d/bootstrap.yaml':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '600',
    content => to_yaml($facter_seed_facts),
  }
}
