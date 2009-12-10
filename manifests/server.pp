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
            "puppet://$server/site-mysql/${fqdn}/my.cnf",
            "puppet://$server/site-mysql/my.cnf",
            "puppet://$server/mysql/config/my.cnf.${operatingsystem}",
            "puppet://$server/mysql/config/my.cnf"
        ],
        ensure => file,
        require => Package['mysql-server'],
        notify => Service['mysqld'],
        owner => root, group => 0, mode => 0644;
    }

    # root password
    if ! $mysql_rootpw {
        fail('You need to define a mysql root password via $mysql_rootpw!')
    }
    file{'/root/.my.cnf':
        content => template('mysql/root/my.cnf.erb'),
        owner => root, group => 0, mode => 0400;
    }
    file{'/usr/local/bin/set_mysql_rootpw.sh':
        source => "puppet://$server/mysql/config/${operatingsystem}/set_mysql_rootpw.sh",
        owner => root, group => 0, mode => 0600;
    }        
    exec{'set_mysql_rootpw':
        command => "/usr/local/bin/set_mysql_rootpw.sh $mysql_rootpw",
        unless => "mysqladmin -u root status > /dev/null",
        require => [
            File['/usr/local/bin/set_mysql_rootpw.sh'], 
            Package['mysql-server'],
            Package['mysql'],
        ],
    }

    # daily dump
    file{'/etc/cron.d/mysql_backup.cron':
        source => [
            "puppet://$server/mysql/backup/mysql_backup.cron.${operatingsystem}",
            "puppet://$server/mysql/backup/mysql_backup.cron",
        ],
        require => [
            Exec['set_mysql_rootpw'],
            File['/root/.my.cnf']
        ],
        owner => root, group => 0, mode => 0600;
    }

    # weekly optimization
    file{'/etc/cron.weekly/mysql_optimize_tables.rb':
        source => "puppet://$server/mysql/optimize/optimize_tables.rb",
        require => [
            Exec['set_mysql_rootpw'],
            File['/root/.my.cnf']
        ],
        owner => root, group => 0, mode => 0700;
    }

    # Collect all databases and users
    Mysql_database<<| tag == "mysql_${fqdn}" |>>
    Mysql_user<<| tag == "mysql_${fqdn}"  |>>
    Mysql_grant<<| tag == "mysql_${fqdn}" |>>
}
