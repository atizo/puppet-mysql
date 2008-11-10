# manifests/perl.pp

class mysql::perl {
    package{'perl-DBD-MySQL':
        ensure => installed,
    }
}
