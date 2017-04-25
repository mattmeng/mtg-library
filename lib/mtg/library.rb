require 'mtg/database'

module Mtg
  class Library
    def initialize( db )
      raise ArgumentError, "db provided was not an Mtg::Database object." unless db.class == Mtg::Database

      @db = db
    end
  end
end
