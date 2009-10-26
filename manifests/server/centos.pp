class mysql::server::centos inherits mysql::server {
    Service[mysql]{
        name  => 'mysqld',
    }
    File['/etc/mysql/my.cnf']{
        path => '/etc/my.cnf',
    }
}
