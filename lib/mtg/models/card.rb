require 'mtg_sdk'

module Mtg
  class Card < Sequel::Model
    unrestrict_primary_key

    attr_accessor :info

    def quantity
      return standard_quantity + foil_quantity
    end

    def self.find_all_by_name( name )
      yield( :searching ) if block_given?
      card_infos = MTG::Card.where( name: name ).where( orderBy: 'name' ).all

      # Lookup or insert into database if necessary.
      cards = []
      card_infos.each_with_index do |card_info, index|
        yield( :parsing, index + 1, card_infos.count ) if block_given?

        unless( card = Card.find( id: card_info.id ) )
          # We don't have the card in our db.  Add it.
          card = Card.create( id: card_info.id, name: card_info.name )
        end

        card.info = card_info
        cards << card
      end

      return cards
    end
  end
end
