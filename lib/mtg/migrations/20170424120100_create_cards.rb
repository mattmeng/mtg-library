Sequel.migration do
  change do
    create_table( :cards ) do
      String :id, primary_key: true
      String :name
      Integer :standard_quantity, default: 0
      Integer :foil_quantity, default: 0
      Float :low_price, default: 0.0
      Float :average_price, default: 0.0
      Float :high_price, default: 0.0
      Float :foil_price, default: 0.0
      DateTime :price_last_updated, null: true
      Integer :mtg_stocks_id, null: true
      index :name
      index :price_last_updated
      index :mtg_stocks_id
    end
  end
end
