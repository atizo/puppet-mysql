# manifests/munin.pp

class mysql::munin {
    munin::plugin {
        [mysql_bytes, mysql_queries, mysql_slowqueries, mysql_threads]:
    }
}
