class mysql::selinux {
  case $operatingsystem {
    gentoo: { include mysql::selinux::gentoo }
  }
}
