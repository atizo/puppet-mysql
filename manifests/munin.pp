class mysql::munin(
  $munin_mysql_password
) {
  mysql_user{'munin@localhost':
    password_hash => mysql_password($munin_mysql_password),
    require => Package['mysql-server'],
  }
  mysql_grant{'munin@localhost':
    privileges => 'select_priv',
    require => [
      Mysql_user['munin@localhost'],
      Package['mysql-server'],
    ],
  }
  munin::plugin{[
    'mysql_bytes',
    'mysql_queries',
    'mysql_slowqueries',
    'mysql_threads',
  ]:
    config => "env.mysqlopts --user=munin --password='$munin_mysql_password' -h localhost",
    require => [
      Mysql_grant['munin@localhost'],
      Mysql_user['munin@localhost'],
      Package['mysql'],
    ],
  }
}
