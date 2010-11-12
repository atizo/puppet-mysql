class mysql::server {
  include mysql::client

  # package and service
  package{'mysql-server':
    ensure => present,
  }
  service{'mysql':
    ensure => running,
    enable => true,
    hasstatus => true,
    require => Package['mysql-server'],
  }
  file{'/etc/mysql/my.cnf':
    source => [
      "puppet://$server/modules/site-mysql/$fqdn/my.cnf",
      "puppet://$server/modules/site-mysql/my.cnf",
      "puppet://$server/modules/mysql/my.cnf.$operatingsystem",
      "puppet://$server/modules/mysql/my.cnf"
    ],
    ensure => file,
    require => Package['mysql-server'],
    notify => Service['mysqld'],
    owner => root, group => 0, mode => 0644;
  }

  # root password
  if ! $mysql::root_password {
    fail('You need to define a mysql root password via init class parameter $root_password!')
  }
  file{'/root/.my.cnf':
    content => template('mysql/my.cnf.erb'),
    owner => root, group => 0, mode => 0400;
  }
  file{'/usr/local/sbin/set_mysql_root_password.sh':
    source => "puppet://$server/mysql/set_mysql_root_password.sh.$operatingsystem",
    owner => root, group => 0, mode => 0700;
  }        
  exec{'set_mysql_root_password':
    command => "/usr/local/sbin/set_mysql_root_password.sh '$mysql::root_password'",
    unless => "mysqladmin -u root status",
    require => [
      File['/usr/local/sbin/set_mysql_root_password.sh'],
      File['/root/.my.cnf'],
      Package['mysql'],
      Service['mysqld'],
    ],
  }

  # daily dump
  file{'/etc/cron.d/mysql_backup.cron':
    source => [
      "puppet://$server/modules/mysql/mysql_backup.cron.$operatingsystem",
      "puppet://$server/modules/mysql/mysql_backup.cron",
    ],
    require => [
      Exec['set_mysql_root_password'],
      File['/root/.my.cnf']
    ],
    owner => root, group => 0, mode => 0600;
  }

  # weekly optimization
  file{'/etc/cron.weekly/mysql_optimize_tables.rb':
    source => "puppet://$server/modules/mysql/optimize_tables.rb",
    require => [
      Exec['set_mysql_root_password'],
      File['/root/.my.cnf']
    ],
    owner => root, group => 0, mode => 0700;
  }

  # Collect all databases and users
  Mysql_database<<| tag == "mysql_$fqdn" |>>
  Mysql_user<<| tag == "mysql_$fqdn"  |>>
  Mysql_grant<<| tag == "mysql_$fqdn" |>>
}
