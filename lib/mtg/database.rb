require 'mtg/constants'
require 'sequel'

module Mtg
  class Database
    def initialize( database_path )
      Sequel.extension :migration
      @db = Sequel.connect( "sqlite://#{database_path}" )
      Sequel::Migrator.run( @db, Mtg::MIGRATIONS_PATH )
    end
  end
end
