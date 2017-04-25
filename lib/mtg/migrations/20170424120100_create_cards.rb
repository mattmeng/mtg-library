Sequel.migration do
  change do
    create_table( :cards ) do
      String :id, primary_key: true
      String :name
      Integer :standard_quantity
      Integer :foil_quantity
      index :name
    end
  end
end
