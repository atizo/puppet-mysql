# install mysql-server in a disabled state
class mysql::disable {
    package{'mysql-server':
        ensure => installed,
    }
    service{'mysql':
       ensure => stopped,
       enable => false,
       hasstatus => true,
       require => Package['mysql-server'],
   }
}
