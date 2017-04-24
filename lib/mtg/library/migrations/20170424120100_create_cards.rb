Sequel.migration do
  change do
    create_table( :cards ) do
      String :id, primary_key: true
      Integer :quantity
    end
  end
end
