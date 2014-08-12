class bareos::web (
  $db_pass,
  $db_user = 'bareos',
  $db_name = 'bareos',
  $db_host = 'localhost',
  $sudo = false,
  $bareos_web_template = "bareos/webareos_config.ini.erb",
  $auth_user_file = "/etc/httpd/conf/webareos.users",
) inherits bareos::params {
    include apache::params
    include apache::service

    package { $bareos::params::webareos_pkgs: ensure => latest, notify => Class['apache::service'] }
    package { $apache::params::mod_packages['ssl']: ensure => latest, notify => Class['apache::service'] }

    augeas { 'set webareos access':
        context => "/files$bareos::params::webareos_conf",
        changes => [
                    "rm Directory[arg='$bareos::params::webareos_dir']/directive[.='Deny']",
                    "set Directory[arg='$bareos::params::webareos_dir']/directive[.='Allow']/arg[2] all",
                    "set Directory[arg='$bareos::params::webareos_dir']/directive[.='AuthType'] AuthType",
                    "set Directory[arg='$bareos::params::webareos_dir']/directive[.='AuthType']/arg Basic",
                    "set Directory[arg='$bareos::params::webareos_dir']/directive[.='AuthName'] AuthName",
                    "set Directory[arg='$bareos::params::webareos_dir']/directive[.='AuthName']/arg Webareos",
                    "set Directory[arg='$bareos::params::webareos_dir']/directive[.='AuthUserFile'] AuthUserFile",
                    "set Directory[arg='$bareos::params::webareos_dir']/directive[.='AuthUserFile']/arg ${bareos::params::webareos_user_auth}",
                    "set Directory[arg='$bareos::params::webareos_dir']/directive[.='Require'] Require",
                    "set Directory[arg='$bareos::params::webareos_dir']/directive[.='Require']/arg valid-user",
                   ],
        require => [Package[$bareos::params::webareos_pkgs],Package[$apache::params::mod_packages['ssl']]],
        notify => Class['apache::service'],
    }

    exec { 'fix webareos index.php':
        command => "sed -i 's/\(^define(.BACULA_VERSION., *\)\([0-9]*\)/\114/' $bareos::params::webareos_index",
        path    => [ "/bin", "/usr/bin" ],
        unless  => "grep -q '^define(.BACULA_VERSION., *14' $bareos::params::webareos_index",
        require => Package[$bareos::params::webareos_pkgs]
    }

    file { $bareos::params::webareos_user_auth:
        owner   => root,
        group   => root,
        mode    => 644,
        source  => $auth_user_file,
        require => Package[$bareos::params::webareos_pkgs],
    }

    file { "/etc/webareos/config.ini":
        owner   => root,
        group   => root,
        mode    => 644,
        content => template($bareos_web_template),
        require => Package[$bareos::params::webareos_pkgs],
    }
}

