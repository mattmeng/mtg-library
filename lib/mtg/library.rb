require "mtg/library/version"
require 'mtg/library/database'

module Mtg
  class Library
    def initialize( database_path )
      @db = Mtg::Database.new( database_path )

      @db.initialize! if @db.initialize?
    end
  end
end
