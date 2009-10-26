class mysql::server::gentoo inherits mysql::server {
    Package[mysql-server] {
        alias => 'mysql',
        category => 'dev-db',
    }
}
