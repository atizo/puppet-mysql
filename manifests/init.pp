#
# mysql module
#
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# Copyright 2008, admin(at)immerda.ch
# Copyright 2008, Puzzle ITC GmbH
# Marcel Härry haerry+puppet(at)puzzle.ch
# Simon Josi josi+puppet(at)puzzle.ch
#
# This program is free software; you can redistribute 
# it and/or modify it under the terms of the GNU 
# General Public License version 3 as published by 
# the Free Software Foundation.
#

class mysql {
    case $operatingsystem {
        gentoo: { include mysql::server::gentoo }
        centos: { include mysql::server::centos }
        default: { include mysql::server } 
    }
    if $selinux {
        include mysql::selinux
    }
    if $use_munin {
        include mysql::munin
    }
}
