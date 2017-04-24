require 'sequel'

module Mtg
  class Database
    def initialize( database_path )
      @db = Sequel.connect( "sqlite://#{database_path}" )
      initialize! if initialize?
      migrate_0_1_0
    end

    def initialize?
      @db[:settings].first rescue return true
      return false
    end

    def initialize!
      @db.create_table( :settings ) do
        primary_key :id
        String :key, size: 50
        String :value
        index :key, unique: true
      end
      @db[:settings].insert( key: 'version', value: '0.0.0' )
    end

    def migrate_0_1_0
      @db.create_table( :cards ) do
        primary_key :id
        String :name
        
      end
    end
  end
end
