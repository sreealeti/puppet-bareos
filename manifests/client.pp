#
class bareos::client (
  $bareos_fd_pass	= $bareos::params::default_pass,
  $bareos_mon_pass	= $bareos::params::default_pass,
  $bareos_fd_name      = $bareos::params::bareos_fd_name,
  $bareos_fd_port      = $bareos::params::bareos_fd_port,
  $bareos_dir_name     = $bareos::params::bareos_dir_name,
  $bareos_mon_name     = $bareos::params::bareos_mon_name,
  $max_concurrent_jobs = $bareos::params::max_concurrent_jobs,
) inherits bareos::params {
   package { $bareos::params::bareos_client_pkgs: ensure => latest }

   service { $bareos::params::bareos_client_service:
      ensure  => running,
      enable  => true,
      require => Package[$bareos::params::bareos_client_pkgs],
   }

   file { $bareos::params::bareos_fd_path:
      owner   => root,
      group   => root,
      mode    => 640,
      require => Package[$bareos::params::bareos_client_pkgs],
      content => template($bareos::params::bareos_fd_tmpl),
      notify  => Service[$bareos::params::bareos_client_service]
   }
}
