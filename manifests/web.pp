class bareos::web (
  $db_pass,
  $db_user = $bareos::params::bareos_db_user,
  $db_name = $bareos::params::bareos_db_name,
  $db_host = $bareos::params::bareos_db_host,
  $webacula_config_temp = "bareos/webacula_config.ini.erb",
  $webacula_db_inst_temp = "bareos/webacula_db.conf.erb",
  $webacula_timezone ='America/Denver',
) inherits bareos::params {
    include apache::params
    include apache::service

    package { $bareos::params::webacula_pkgs: ensure => latest, notify => Class['apache::service'] }
    package { $apache::params::mod_packages['ssl']: ensure => latest, notify => Class['apache::service'] }

    exec { 'fix webacula index.php':
        command => "sed -i 's/\(^define(.BACULA_VERSION., *\)\([0-9]*\)/\114/' $bareos::params::webacula_index",
        path    => [ "/bin", "/usr/bin" ],
        unless  => "grep -q '^define(.BACULA_VERSION., *14' $bareos::params::webacula_index",
        require => Package[$bareos::params::webacula_pkgs]
    }

    file { $bareos::params::webacula_user_auth:
        owner   => root,
        group   => root,
        mode    => 644,
        source  => $auth_user_file,
        require => Package[$bareos::params::webacula_pkgs],
    }

    file { "/etc/webacula/config.ini":
        owner   => root,
        group   => root,
        mode    => 644,
        content => template($bareos_web_template),
        require => Package[$bareos::params::webacula_pkgs],
    }
}

