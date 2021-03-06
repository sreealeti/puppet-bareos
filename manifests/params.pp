#
class bareos::params {
	$default_pass		= 'changeme'
	$bareos_dir_name	= 'bareos-dir'
	$bareos_dir_port	= 9101
	$bareos_dir_address	= "${hostname}"
	$bareos_mon_name	= 'bareos-mon'
	$bareos_sd_name		= "${hostname}"
	$bareos_sd_port		= 9103
	$bareos_db_backend	= 'mysql'
	$bareos_db_host		='localhost'
	$bareos_db_name		= 'bareos'
	$bareos_db_user		= 'bareos'
	$bareos_manage_db	= 'true'
	$bareos_fd_name      	= "${hostname}"
	$bareos_fd_port		= 9102
	$repo_url		= 'http://changeme'
	$max_concurrent_jobs	= 30

  case $::osfamily {
    'RedHat': {
      $bconsole_tmpl      = 'bareos/bconsole.conf.erb'
      $bconsole_path      = '/etc/bareos/bconsole.conf'
      $bareos_dir_tmpl    = 'bareos/bareos-dir.conf.erb'
      $bareos_dir_path    = '/etc/bareos/bareos-dir.conf'
      $bareos_sd_tmpl     = 'bareos/bareos-sd.conf.erb'
      $bareos_sd_path     = '/etc/bareos/bareos-sd.conf'
      $bareos_fd_path     = '/etc/bareos/bareos-fd.conf'
      $bareos_fd_tmpl     = 'bareos/bareos-fd.conf.erb'
      $webacula_conf      = '/var/www/webacula/application/config.ini'
      $webacula_db_inst   = '/var/www/webacula/install/db.conf'
      $webacula_pkgs      = ['webacula', 'php-ZendFramework-Db-Adapter-Pdo-Mysql-1.12.7-1.el7.centos']
      $bareos_client_pkgs = ['bareos-client']
      $bareos_server_pkgs = ['bareos', 'bareos-database-mysql']
      $bareos_client_service = 'bareos-fd'
      $bareos_dir_service    = 'bareos-dir'
      $bareos_sd_service     = 'bareos-sd'
    	}
    default: {
    	}
  }
	$repo_flavour = 'latest'
	$repo_distro = $::operatingsystem ? {
                        /(?i:redhat|centos|scientific|oraclelinux|fedora)/ => "${::operatingsystem}_6",
                        default                                            => 'UNKNOWN',
                        }
#install repository with bareos packages
        require bareos::repository

}
