class bareos::web (
  $db_pass,
  $db_user = $bareos::params::bareos_db_user,
  $db_name = $bareos::params::bareos_db_name,
  $db_host = $bareos::params::bareos_db_host,
  $webacula_config_temp = "bareos/webacula_config.ini.erb",
  $webacula_db_inst_temp = "bareos/webacula_db.conf.erb",
  $webacula_timezone ='America/Denver',
  $web_pass = 'changeme',
) inherits bareos::params {
    #include apache::params
    #include apache::service

    package { $bareos::params::webacula_pkgs: ensure => installed }
    #package { $apache::params::mod_packages['ssl']: ensure => latest, notify => Class['apache::service'] }

    file { "/var/www/webacula/application/config.ini":
        owner   => root,
        group   => root,
        mode    => 644,
        content => template($webacula_config_temp),
        require => Package[$bareos::params::webacula_pkgs],
    }
    
    file { "/var/www/webacula/install/db.conf":
        owner   => root,
        group   => root,
        mode    => 644,
        content => template($webacula_db_inst_temp),
        require => Package[$bareos::params::webacula_pkgs],
	notify   => Exec["make_webacula_tables"]
    }
    
    exec { 'make_webacula_tables':
                                        command     => "/var/www/webacula/install/MySql/10_make_tables.sh && /var/www/webacula/install/MySql/20_acl_make_tables.sh",
                                        refreshonly => true,
                                        require => Package[$bareos::params::webacula_pkgs],
                                        }
}

