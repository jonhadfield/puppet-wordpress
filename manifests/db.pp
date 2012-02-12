class wordpress::db {
	
	$mysqlserver = $::operatingsystem ? {
		Ubuntu => mysql-server,
		CentOS => mysql-server,
		default => mysql-server
	}

	$mysqlclient = $::operatingsystem ? {
		Ubuntu => mysql-client,
		CentOS => mysql,
		Debian => mysql-client,
		default => mysql
	}

	$mysqlservice = $::operatingsystem ? {
		Ubuntu => mysql,
		CentOS => mysqld,
		Debian => mysql,
		default => mysqld
	}

	package { ["${mysqlclient}", "${mysqlserver}"]: ensure => latest }

	service { "${mysqlservice}":
		ensure     => running,
		enable     => true,
		hasrestart => true,
		hasstatus  => true,
		require    => Package["${mysqlserver}", "${mysqlclient}"],
	}

	file { "wordpress_sql_script":
			path    =>  "/opt/wordpress/setup_files/create_wordpress_db.sql",
			ensure  =>  file,
			content	=> template("wordpress/create_wordpress_db.erb");
	}

	exec { 
		"create_schema":
			path    => "/usr/bin:/usr/sbin:/bin",
			command => "mysql -uroot < /opt/wordpress/setup_files/create_wordpress_db.sql",
			unless  => "mysql -uroot -e \"use ${wordpress::db_name}\"",
			notify  => Exec["grant_privileges"],
			require => [ 
				Service["${mysqlservice}"], 
				File["wordpress_sql_script"],
			];

		"grant_privileges":
			path    => "/usr/bin:/usr/sbin:/bin",
			command => "mysql -uroot -e \"grant all privileges on ${wordpress::db_name}.* to '${wordpress::db_user}'@'localhost' identified by '${wordpress::db_password}'\"",
			unless  => "mysql -u${wordpress::db_user} -p${wordpress::db_password} -D${wordpress::db_name} -hlocalhost",
			refreshonly => true;
  	}   
}
