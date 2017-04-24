Sequel.migration do
  change do
    create_table( :settings ) do
      primary_key :id
      String :key, size: 50
      String :value
      index :key, unique: true
    end

    self[:settings].insert( key: 'version', value: '0.0.0' )
  end
end
