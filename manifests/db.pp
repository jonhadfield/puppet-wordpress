class wordpress::db (
  $create_db,
  $create_db_user,
  $db_name,
  $db_host,
  $db_user,
  $db_password,
) {
  validate_bool($create_db,$create_db_user)
  validate_string($db_name,$db_host,$db_user,$db_password)

  ## PHP MySQL support
  case $::osfamily {
    'Debian': {
      $php_mysql = 'php5-mysql'
    }
    'RedHat': {
      $php_mysql = $::lsbmajdistrelease ? {
        '5' => 'php53-mysql',
        '6' => 'php-mysql',
      }
    }
  }
  if ! defined(Package[$php_mysql]) {
    package { $php_mysql:
      ensure  => present,
      require => Class['apache::mod::php'],
    }
  }

  ## Set up DB using puppetlabs-mysql defined type
  if $create_db {
    database { $db_name:
      charset => 'utf8',
      require => Class['wordpress::app'],
    }
  }
  if $create_db_user {
    database_user { "${db_user}@${db_host}":
      password_hash => mysql_password($db_password),
      require       => Class['wordpress::app'],
    }
    database_grant { "${db_user}@${db_host}/${db_name}":
      privileges => ['all'],
      require    => Class['wordpress::app'],
    }
  }

}
