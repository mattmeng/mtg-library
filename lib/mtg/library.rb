require 'mtg/database'

module Mtg
  class Library
    def initialize( database_path )
      @db = Mtg::Database.new( database_path )
    end
  end
end
