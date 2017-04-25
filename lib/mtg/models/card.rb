module Mtg
  class Card < Sequel::Model
    def quantity
      return standard_quantity + foil_quantity
    end
  end
end
