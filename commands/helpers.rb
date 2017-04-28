require 'word_wrap'
require 'word_wrap/core_ext'
require 'paint'

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

def rarity_colors( rarity )
  case rarity
  when "Common"
    return ['696969', '808080']
  when "Uncommon"
    return ['778899', 'C0C0C0']
  when "Rare"
    return ['FFAF00', 'FFDD00']
  when "Mythic Rare"
    return ['FF4500', 'FF8C00']
  else
    return ['4169E1', '87CEFA']
  end
end

def rarity_label( rarity, short_hand: true )
  rtvnal = rarity.clone

  if short_hand
    case rarity
    when "Common"
      rtnval = "C"
    when "Uncommon"
      rtnval = "U"
    when "Rare"
      rtnval = "R"
    when "Mythic Rare"
      rtnval = "MR"
    else
      rtnval = "S"
    end
  end

  return Paint[rtnval, rarity_colors( rarity )[0]]
end

def card_colors( colors )
  return ['696969', 'A9A9A9', '000000'] unless colors

  colors = [colors] if colors.class == String
  return ['DAA520', 'EEB934', '000000'] if colors.count > 1

  case colors[0]
  when 'White', 'W'
    return ['B4B4B4', 'FFFFFF', '000000']
  when 'Blue', 'U'
    return ['1E90FF', '6495ED', '000000']
  when 'Black', 'B'
    return ['333333', '555555', 'FFFFFF']
  when 'Red', 'R'
    return ['B40000', 'FF5050', '000000']
  when 'Green', 'G'
    return ['006400', '329632', '000000']
  end
end

def get_card( name )
  spinner = TTY::Spinner.new(
    ":spinner Searching for cards...",
    format: :dots,
    clear: true,
    hide_cursor: true
  )
  progress = nil
  cards = []
  card = nil

  if name
    screen( 1 ) do
      cards = Mtg::Card.find_all_by_name( name ) do |status, index, count|
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
            "#{c.name} (#{c.source || c.set_name} - #{Paint[rarity_label( c.rarity, short_hand: true ), :bold]})",
            c.id]}
          ]
        )
      end
      card = cards.select {|c| c.id == card_id}.first
    end
  end

  return card
end

def display_card( card )
  height, width = TTY::Screen.size

  primary, accent, text = card_colors( card.colors )
  r_primary, r_accent, r_text = rarity_colors( card.rarity )

  puts
  puts Paint[' ', nil, primary, :bright] +
    Paint[" #{card.name}", text, accent, :bold] +
    Paint[(' ' * (width - 2 - card.name.size)), nil, accent]
  puts Paint['┃', primary]
  puts Paint['┃ Mana Cost ', primary] + symbols( card.mana_cost )
  puts Paint['┃ Image URL ', primary] + card.image_url
  puts Paint['┃ Type      ', primary] + card.type
  puts Paint['┃ Rarity    ', primary] + Paint[card.rarity, r_primary, :bold]
  puts Paint['┃ Set       ', primary] + (card.source || card.set_name)
  puts Paint['┃ P/T       ', primary] + "#{card.power}/#{card.toughness}" if card.types.include?( "Creature" )
  puts Paint['┃ Loyalty   ', primary] + card.loyalty.to_s if card.types.include?( "Planeswalker" )

  puts
  puts Paint['Text', 'DCDCDC', :bold]
  puts
  symbols( card.text ).split( /\n/ ).each_with_index do |text, index|
    puts Paint['┃', 'D2B48C'] unless index == 0
    text.fit( 60 ).split( /\n/ ).each do |line|
      puts Paint["┃ #{line}", 'D2B48C']
    end
  end

  if card.rulings
    puts
    puts Paint['Rulings', 'DCDCDC', :bold]
    puts
    card.rulings.each_with_index do |ruling, index|
      puts Paint['┃', '696969'] unless index == 0
      "#{ruling.date}: #{symbols( ruling.text )}".fit( 60 ).split( /\n/ ).each do |line|
        puts Paint["┃ #{line}", '696969']
      end
    end
  end

  puts
  puts Paint['Metadata', :white, :bold]
  puts
  puts Paint['┃ ID                ', '90EE90'] + card.id
  puts Paint['┃ Standard Quantity ', '90EE90'] + card.standard_quantity.to_s
  puts Paint['┃ Foil Quantity     ', '90EE90'] + card.foil_quantity.to_s
end
