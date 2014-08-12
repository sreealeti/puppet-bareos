#
class bareos::repository inherits bareos::params {

  case $::operatingsystem {

    redhat,centos,fedora,Scientific,OracleLinux: {
      file { 'bareos.repo':
        path    => '/etc/yum.repos.d/bareos.repo',
        content => template('bareos/bareos.repo.erb'),
      }
    }

    Debian,Ubuntu: {
      file { '/etc/apt/sources.list.d/bareos.list':
        content => "deb http://download.bareos.org/bareos/release/${bareos::repo_flavour}/${bareos::repo_distro} /\n"
      }
      ~>
      exec { 'bareos-key':
        command     => "/usr/bin/wget -q http://download.bareos.org/bareos/release/${bareos::repo_flavour}/${bareos::repo_distro}/Release.key -O- | /usr/bin/apt-key add -",
        refreshonly => true
      }
      ~>
      exec { 'update-apt':
        command     => '/usr/bin/apt-get update',
        refreshonly => true
      }
    }
    default: { fail("${::hostname}: This module does not support operatingsystem ${::operatingsystem}") }
  }
}
