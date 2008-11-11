# manifests/perl.pp

class mysql::perl {
    package{'perl-DBD-mysql':
        ensure => installed,
    }
}
