class mysql::client {
  package{'mysql':
    ensure => present,
  }
}
