require 'mtg/constants'
require 'sequel'

module Mtg
  class Database
    def initialize( database_path )
      # Connect to the given database.
      Sequel.extension :migration
      @db = Sequel.connect( "sqlite://#{database_path}" )

      # Migrate the database to get any new changes.
      Sequel::Migrator.run( @db, Mtg::MIGRATIONS_PATH )

      # Initialize all models.
      Dir[File.join( MODELS_PATH, '*.rb' )].each {|file| load( file )}
    end
  end
end
