require 'word_wrap'
require 'word_wrap/core_ext'
require 'paint'
require 'tty/table'

def screen( lines )
  yield
  print CURSOR.clear_lines( lines + 1, :up )
end

def symbols( text )
  text = text.clone
  text.gsub!( /{(\d+)}/, '\1' ) # Colorless
  text.gsub!( /{W}/, '☼' ) # White
  text.gsub!( /{U}/, '💧' ) # Blue
  text.gsub!( /{B}/, '💀' ) # Black
  text.gsub!( /{R}/, '🔥' ) # Red
  text.gsub!( /{G}/, '🌳' ) # Green
  text.gsub!( /{T}/, '↻' ) # Tap

  return text
end

def rarity_colors( card )
  if card.common?
    return ['696969', '808080']
  elsif card.uncommon?
    return ['778899', 'C0C0C0']
  elsif card.rare?
    return ['FFAF00', 'FFDD00']
  elsif card.mythic_rare?
    return ['FF4500', 'FF8C00']
  else
    return ['4169E1', '87CEFA']
  end
end

def rarity_label( card, short_hand: true )
  if card.common?
    rtnval = 'Common'
    rtnval = 'C' if short_hand
  elsif card.uncommon?
    rtnval = 'Uncommon'
    rtnval = 'U' if short_hand
  elsif card.rare?
    rtnval = 'Rare'
    rtnval = 'R' if short_hand
  elsif card.mythic_rare?
    rtnval = 'Mythic Rare'
    rtnval = 'MR' if short_hand
  else
    rtnval = 'Special'
    rtnval = 'S'
  end

  return Paint[rtnval, rarity_colors( card )[0]]
end

def card_colors( card )
  return ['696969', 'A9A9A9', '000000'] if card.colorless?
  return ['DAA520', 'EEB934', '000000'] if card.multi_colored?
  return ['B4B4B4', 'FFFFFF', '000000'] if card.white?
  return ['1E90FF', '6495ED', '000000'] if card.blue?
  return ['333333', '555555', 'FFFFFF'] if card.black?
  return ['B40000', 'FF5050', '000000'] if card.red?
  return ['006400', '329632', '000000'] if card.green?
end

def get_card( identifier )
  spinner = TTY::Spinner.new(
    ":spinner Searching for cards...",
    format: :dots,
    clear: true,
    hide_cursor: true
  )
  progress = nil
  cards = []

  spinner.auto_spin
  card = Mtg::Card.find_by_id( identifier )
  spinner.stop

  if !card && identifier
    screen( 1 ) do
      cards = Mtg::Card.find_all_by_name( identifier ) do |status, index, count|
        case status
        when :searching
          spinner.auto_spin
        when :parsing
          spinner.stop
          unless progress
            progress = TTY::ProgressBar.new(
              ":bar Parsing :current/:total",
              total: count,
              width: 40,
              complete: Paint[' ', nil, :green, :bright],
              incomplete: Paint[' ', nil, :white]
            )
          end
          progress.advance
        end
      end
    end

    if cards.count == 1
      card = cards.first
    elsif cards.count > 1
      card_id = nil
      screen( 1 ) do
        card_id = PROMPT.select(
          "Which card did you mean?",
          Hash[cards.map {|c| [
            "#{c.name} (#{c.source || c.set_name} - #{Paint[rarity_label( c, short_hand: true ), :bold]})",
            c.id]}
          ]
        )
      end
      card = cards.select {|c| c.id == card_id}.first
    end
  end

  return card
end

def header1( value, primary_color, accent_color, text_color )
  height, width = TTY::Screen.size

  puts
  puts Paint[' ', nil, primary_color] +
    Paint[" #{value}", text_color, accent_color, :bold] +
    Paint[(' ' * (width - 2 - value.size)), nil, accent_color]
  puts Paint['┃', primary_color]
end

def header2( value )
  puts
  puts Paint[value, 'DCDCDC', :bold]
  puts
end

def data( primary_color, hash )
  max_length = hash.keys.max_by( &:length ).length
  hash.each do |header, text|
    puts Paint["┃ #{header.rjust( max_length ) + ' '}", primary_color] + text.to_s if text
  end
end

def text( value, primary_color )
  puts Paint["┃ #{value}", primary_color]
end

def check_card_price( card )
  unless card.mtg_stocks_id
    screen( 1 ) do
      id = PROMPT.ask(
        "What is the mtgstocks.com card id for #{Paint[card.name, card_colors( card )[0]]}?",
        convert: :int
      ) {|q| q.validate /^\d+$/}
    end
    card.update( mtg_stocks_id: id )
  end

  card.get_prices
end

def display_card( card )
  primary, accent, text_color = card_colors( card )
  r_primary, r_accent, r_text = rarity_colors( card )

  check_card_price( card )

  header1( card.name, primary, accent, text_color )
  data( primary, {
    'Mana Cost' => symbols( card.mana_cost ),
    'Image URL' => card.image_url,
    'Artist' => card.artist,
    'Type' => card.type,
    'Rarity' => Paint[card.rarity, r_primary, :bold],
    'Set' => (card.source || card.set_name),
    'P/T' => "#{card.power}/#{card.toughness}",
    'Loyalty' => card.loyalty
  } )

  header2( 'Text' )
  symbols( card.text ).split( /\n/ ).each_with_index do |line, index|
    text( '', 'D2B48C' ) unless index == 0
    line.fit( 60 ).split( /\n/ ).each do |line|
      text( line, 'D2B48C' )
    end
  end

  if card.rulings
    header2( 'Rulings' )
    card.rulings.each_with_index do |ruling, index|
      text( '', '696969' ) unless index == 0
      "#{ruling.date}: #{symbols( ruling.text )}".fit( 60 ).split( /\n/ ).each do |line|
        text( line, '696969' )
      end
    end
  end

  table = TTY::Table.new( header: ['Quality', 'Online', 'Library'] )
  table << ['Low', card.low_price, (card.low_price * card.standard_quantity).round( 2 )]
  table << ['Average', card.average_price, avg = (card.average_price * card.standard_quantity).round( 2 )]
  table << ['High', card.high_price, (card.high_price * card.standard_quantity).round( 2 )]
  table << ['Foil', card.foil_price, foil = (card.foil_price * card.foil_quantity).round( 2 )]
  table << ['Total (Average)', '-', (avg + foil).round( 2 )]

  header2( 'Metadata' )
  data( '90EE90', {
    'ID' => card.id,
    'Multiverse ID' => card.multiverse_id,
    'MTGStocks ID' => card.mtg_stocks_id,
    'Standard Quantity' => card.standard_quantity,
    'Foil Quantity' => card.foil_quantity
  } )
  text( '', '90EE90' )
  table.render( :unicode ).split( /\n/ ).each do |line|
    text( line, '90EE90' )
  end

  puts
end

def add_cards( card )
  card.standard_quantity = card.standard_quantity + PROMPT.ask(
    "Add standard cards:",
    default: 0,
    convert: :int
  )

  card.foil_quantity = card.foil_quantity + PROMPT.ask(
    "Add foil cards:",
    default: 0,
    convert: :int
  )

  card.save
end

def remove_cards( card )
  if card.standard_quantity > 0
    card.standard_quantity = PROMPT.slider(
      "Set total standard cards:",
      min: 0,
      max: card.standard_quantity,
      step: 1
    )
  end

  if card.foil_quantity > 0
    card.foil_quantity = PROMPT.slider(
      "Set total foil cards:",
      min: 0,
      max: card.foil_quantity,
      step: 1
    )
  end

  card.save
end

def update_prices
  screen( 1 ) do
    cards = Mtg::Card.cards_with_price()
    progress = TTY::ProgressBar.new(
      ":bar Updating prices :current/:total",
      total: cards.count,
      width: 40,
      complete: Paint[' ', nil, :green, :bright],
      incomplete: Paint[' ', nil, :white]
    )

    cards.each do |card|
      check_card_price( card )
      progress.advance
    end
  end
end

def library_status
  primary = '2196F3'
  accent = '4FC3F7'
  text_color = '000000'

  header1( 'Library Status', primary, accent, text_color )
  data( primary, {
    'Mana Cost' => 'asdf',
    'Image URL' => 'asdf'
  } )
end
