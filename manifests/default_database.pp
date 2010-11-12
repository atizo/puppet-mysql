# create default database
# generate hashed password with:
# ruby -r'digest/sha1' -e 'puts "*" + Digest::SHA1.hexdigest(Digest::SHA1.digest(ARGV[0])).upcase' PASSWORD
define mysql::default_database(
  $username = false,
  $password = false,
  $password_is_encrypted = true,
  $privileges = 'all',
  $host = 'localhost',
  $ensure = 'present'
){
  require mysql::server
  if $username {
    $real_username = $username
  } else {
    $real_username = $name
  }
  mysql_database{$name:
    ensure => $ensure,
  }
  if ! $password {
    info("we don't create the user for database: $name")
    $grant_require = Mysql_database[$name]
  } else {
    mysql_user{"$real_username@$host":
      password_hash => $password_is_encrypted ? {
        true => $password,
        default => mysql_password($password)
      },
      ensure => $ensure,
      require => Mysql_database[$name],
    }
    $grant_require = [
      Mysql_database[$name],
      Mysql_user["$real_username@$host"]
    ]
  }
  mysql_grant{"$real_username@$host/$name":
    privileges => $privileges,
    require => $grant_require,
  }
}
