#######################################
# mysql module
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.
# adapted by Puzzle ITC - haerry+puppet(at)puzzle.ch
#######################################

# modules_dir { "mysql": }

class mysql::server {

	package { "mysql-server":
		ensure => installed,
	}

    if $use_munin {
        include mysql::munin
	}

	service { mysql:
		ensure => running,
		hasstatus => true,
		require => Package["mysql-server"],
	}

	# Collect all databases and users
	Mysql_database<<| tag == "mysql_${fqdn}" |>>
	Mysql_user<<| tag == "mysql_${fqdn}" |>>
	Mysql_grant<<||>>

}
