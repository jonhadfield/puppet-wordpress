class wordpress::app {

	$wordpress_archive = "wordpress-3.3.1.zip"

	$apache = $::operatingsystem ? {
		Ubuntu => apache2,
		CentOS => httpd,
		Debian => apache2,
		default => httpd
	}

	$phpmysql = $::operatingsystem ? {
		Ubuntu => php5-mysql,
		CentOS => php-mysql,
		Debian => php5-mysql,
		default => php-mysql
	}

	$php = $::operatingsystem ? {
		Ubuntu => php5,
		CentOS => php,
		Debian => php5,
		default => php
	}

	package { ["${apache}","${php}","${phpmysql}"]: 
		ensure => latest 
	}

	service { $apache:
		ensure     => running,
		enable     => true,
		hasrestart => true,
		hasstatus  => true,
		require    => Package["${apache}", "${php}", "${phpmysql}"],
		subscribe  => File["wordpress_vhost"];
	}
	
	file { 
		"wordpress_application_dir":
			path    =>  "/opt/wordpress",
			ensure  =>  directory,
			before	=>  File["wordpress_setup_files_dir"];
		"wordpress_setup_files_dir":
			path    =>  "/opt/wordpress/setup_files",
			ensure  =>  directory,
			before	=>  File["wordpress_php_configuration","wordpress_themes","wordpress_plugins","wordpress_installer","wordpress_htaccess_configuration"];
		"wordpress_installer":
			path    =>  "/opt/wordpress/setup_files/${wordpress_archive}",
			ensure  =>  file,
			notify  =>  Exec["wordpress_extract_installer"],
			source  =>  "puppet:///modules/wordpress/${wordpress_archive}";
		"wordpress_php_configuration":
			path       =>  "/opt/wordpress/wp-config.php",
			ensure     =>  file,
			content	   =>  template("wordpress/wp-config.erb"),
			subscribe  =>  Exec["wordpress_extract_installer"];
		"wordpress_htaccess_configuration":
			path       =>  "/opt/wordpress/.htaccess",
			ensure     =>  file,
			source     =>  "puppet:///modules/wordpress/.htaccess",
			subscribe  =>  Exec["wordpress_extract_installer"];
		"wordpress_themes":
			path    =>    "/opt/wordpress/setup_files/themes",
			ensure  =>    directory,
			source	=>    "puppet:///modules/wordpress/themes/",
			recurse =>    true,		
			purge   =>    true,	
			ignore  =>    ".svn",
			notify =>     Exec["wordpress_extract_themes"],
			subscribe =>  Exec["wordpress_extract_installer"];
		"wordpress_plugins":
			path    =>    "/opt/wordpress/setup_files/plugins",
			ensure  =>    directory,
			source	=>    "puppet:///modules/wordpress/plugins/",
			recurse =>    true,		
			purge   =>    true,	
			ignore  =>    ".svn",
			notify =>     Exec["wordpress_extract_plugins"],
			subscribe =>  Exec["wordpress_extract_installer"];
		# TODO: Messy - need to properly set apache2 config and enable in proper way		
		"wordpress_vhost":
			path =>    $apache ? {
				httpd =>    "/etc/httpd/conf.d/wordpress.conf",
				apache2 =>  "/etc/apache2/sites-enabled/000-default",
				default =>  "/etc/httpd/conf.d/wordpress.conf",
			},
			ensure =>   file,
			source =>   "puppet:///modules/wordpress/wordpress.conf",
			replace =>  true,
			require =>  Package["${apache}"];
    	}

	exec {
		"wordpress_extract_installer":
			command => "unzip -o /opt/wordpress/setup_files/${wordpress_archive} -d /opt/",
			refreshonly => true,
			path => ["/bin","/usr/bin","/usr/sbin","/usr/local/bin"];
		"wordpress_extract_themes":
			command => "/bin/sh -c 'for themeindex in `ls /opt/wordpress/setup_files/themes/*.zip`; do unzip -o \$themeindex -d /opt/wordpress/wp-content/themes/; done'",
			path => ["/bin","/usr/bin","/usr/sbin","/usr/local/bin"],
			refreshonly => true,
			subscribe => File["wordpress_themes"];
		"wordpress_extract_plugins":
			command => "/bin/sh -c 'for pluginindex in `ls /opt/wordpress/setup_files/plugins/*.zip`; do unzip -o \$pluginindex -d /opt/wordpress/wp-content/plugins/; done'",
			path => ["/bin","/usr/bin","/usr/sbin","/usr/local/bin"],
			refreshonly => true,
			subscribe => File["wordpress_plugins"];
	}
}
	
