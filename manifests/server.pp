#
class bareos::server (
   $bareos_dir_name     = $bareos::params::bareos_dir_name,
   $bareos_dir_port     = $bareos::params::bareos_dir_port,
   $bareos_dir_address  = $bareos::params::bareos_dir_address,
   $bareos_sd_name      = $bareos::params::bareos_sd_name,
   $bareos_sd_port      = $bareos::params::bareos_sd_port,
   $bareos_mon_name     = $bareos::params::bareos_mon_name,
   $bareos_db_host      = $bareos::params::bareos_db_host,
   $bareos_db_backend	= $bareos::params::bareos_db_backend,
   $bareos_db_name      = $bareos::params::bareos_db_name,
   $bareos_db_user      = $bareos::params::bareos_db_user,
   $bareos_manage_db	= $bareos::params::bareos_manage_db,
   $bconsole_template   = $bareos::params::bconsole_tmpl,
   $bareos_dir_template = $bareos::params::bareos_dir_tmpl,
   $bareos_sd_template  = $bareos::params::bareos_sd_tmpl,
   $max_concurrent_jobs = $bareos::params::max_concurrent_jobs,
   $bareos_db_pass	= $bareos::params::default_pass,
   $bareos_dir_pass	= $bareos::params::default_pass,
   $bareos_sd_pass	= $bareos::params::default_pass,
   $bareos_mon_pass	= $bareos::params::default_pass,
   $mail_from           = '\(Bareos\) \<%r\>',
   $clients             = {},
   $mail_to             = 'bareos@localhost'
) inherits bareos::params {
	
   
#install repository with bareos packages
	require bareos::repository
#install server packages
   	package { $bareos::params::bareos_server_pkgs: ensure => installed }

#install mysql database and populate tables
	if $bareos_manage_db == 'true' {

	#declare variables
	$db_parameters = $bareos_db_backend ? {
    			'sqlite' => '',
    			'mysql'  => "--host=${bareos_db_host} --user=${bareos_db_user} --password=${bareos_db_pass} --database=${bareos_db_name}",
  			}
       		# Install the database
       		case $operatingsystem {
           				fedora: {
               					class { 'mysql': }
               					class { 'mysql::server':
                   					service_provider => systemd,
                   					service_name => 'mariadb.service'
               							}
           					}
           				default: {
               					class { '::mysql::server': }
           					}
      					}
       			mysql::db { $bareos_db_name:
           				user     => $bareos_db_user,
           				password => $bareos_db_pass,
           				host     => $bareos_db_host,
           				grant    => ALL,
           				notify   => Exec["make_db_tables"]
       				}
        		exec { 'make_db_tables':
                        		command     => "/usr/lib/bareos/scripts/make_bareos_tables ${db_parameters}",
                        		refreshonly => true,
					require => Package[$bareos::params::bareos_server_pkgs],
                        		}

   	}		
  

#configure the files for dir,storage and console 
	file { $bareos::params::bconsole_path:
        	owner   => bareos,
        	group   => bareos,
        	mode    => 644,
        	content => template($bconsole_template),
        	require => Package[$bareos::params::bareos_server_pkgs],
   		}

   	file { $bareos::params::bareos_dir_path:
        	owner   => bareos,
        	group   => bareos,
        	mode    => 644,
        	content => template($bareos_dir_template),
        	require => Package[$bareos::params::bareos_server_pkgs],
        	notify  => Service[$bareos::params::bareos_dir_service]
   		}

   	file { $bareos::params::bareos_sd_path:
       		owner   => bareos,
       		group   => bareos,
       		mode    => 640,
       		content => template($bareos_sd_template),
       		require => Package[$bareos::params::bareos_server_pkgs],
       		notify  => Service[$bareos::params::bareos_sd_service]
   		}



# configure services bareos-dir and bareos-sd
   	service { $bareos::params::bareos_dir_service:
       		enable     => true,
       		ensure     => running,
      		 hasrestart => true,
   		}

   	service { $bareos::params::bareos_sd_service:
       		enable     => true,
       		ensure     => running,
       		hasrestart => true,
   		}
}
