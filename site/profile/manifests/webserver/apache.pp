class profile::webserver::apache(

) {
 
  class { 'apache':
    default_vhost => false,
  }

  apache::vhost { 'mirror.seed.raft.conf':
    port        => '80',
    docroot     => '/media/cdrom/mirror/',
    directories => [
      { 
        path    => '/media/cdrom/mirror/',
        options => ['Indexes','FollowSymLinks'],
      }
    ],
  }

}
