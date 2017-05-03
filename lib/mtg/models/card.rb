require 'mtg_sdk'
require 'active_support/core_ext/integer'
require 'mtg/stocks'

module Mtg
  class Card < Sequel::Model
    unrestrict_primary_key

    attr_accessor :info

    def quantity
      return standard_quantity + foil_quantity
    end

    def white?
      return info.colors.include?( 'White' )
    end

    def blue?
      return info.colors.include?( 'Blue' )
    end

    def black?
      return info.colors.include?( 'Black' )
    end

    def red?
      return info.colors.include?( 'Red' )
    end

    def green?
      return info.colors.include?( 'Green' )
    end

    def multi_colored?
      return info.colors.count > 1
    end

    def colorless?
      return info.colors.nil? || info.colors.empty?
    end

    def common?
      return info.rarity == 'Common'
    end

    def uncommon?
      return info.rarity == 'Uncommon'
    end

    def rare?
      return info.rarity == 'Rare'
    end

    def mythic_rare?
      return info.rarity == 'Mythic Rare'
    end

    def special?
      return info.rarity == 'Special'
    end

    def get_prices
      return unless mtg_stocks_id

      unless price_last_updated && (price_last_updated + 1.day < DateTime.now)
        self.low_price, self.average_price, self.high_price, self.foil_price = Mtg::Stocks.card_price( mtg_stocks_id )
        self.update( price_last_updated: DateTime.now )
      end

      return low_price, average_price, high_price, foil_price
    end

    def method_missing( method, *args, &block )
      return info.send( method, *args, &block ) if info
    end

    def self.find_by_id( id )
      card = Card.find( id: id )
      return nil unless card

      cards = MTG::Card.where( name: card.name ).all

      begin
        card.info = cards.shift
      end until card.info.id == card.id

      return card
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
