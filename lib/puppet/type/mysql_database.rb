Puppet::Type.newtype(:mysql_database) do
  @doc = "Manage a database."
  ensurable
  autorequire(:service) { 'mysql' }
  newparam(:name) do
    desc "The name of the database."
    # TODO: only [[:alnum:]_] allowed
  end
end
