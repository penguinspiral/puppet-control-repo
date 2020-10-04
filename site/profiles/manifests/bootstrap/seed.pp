# @summary
#   Unique, singular "seed" node configuration
#   Manually specifies the static "seed" role fact
#
# @example
#   include profiles::bootstrap
#
class profiles::bootstrap::seed() {

  file {
    default:
      owner => 'root',
      group => 'root',
    ;

    ['/etc/facter', '/etc/facter/facts.d']:
      ensure => 'directory',
      mode   => '0755',
    ;

    '/etc/facter/facts.d/bootstrap.yaml':
      ensure  => 'file',
      mode    => '0600',
      content => to_yaml({ role => 'seed' }),
    ;
  }

}
