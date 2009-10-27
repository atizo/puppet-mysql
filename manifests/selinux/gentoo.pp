class mysql::selinux::gentoo {
    package{'selinux-mysql':
        ensure => present,
        category => 'sec-policy',
        require => Package[mysql],
    }
    selinux::loadmodule {'mysql': }
}
