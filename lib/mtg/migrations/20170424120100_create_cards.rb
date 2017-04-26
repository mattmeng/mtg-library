Sequel.migration do
  change do
    create_table( :cards ) do
      String :id, primary_key: true
      String :name
      Integer :standard_quantity, default: 0
      Integer :foil_quantity, default: 0
      index :name
    end
  end
end
