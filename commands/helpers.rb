require 'word_wrap'
require 'word_wrap/core_ext'

def screen( lines )
  yield
  print CURSOR.clear_lines( lines + 1, :up )
end

# 🌣 ☼ 🌞 ☀
# 💧 🌢
# 💀 ☠ 🕱
# 🔥
# 🌲 🌳 🌴 🎄 𐇲 ⸙

def rarity_colors( rarity )
  case rarity
  when "Common"
    bg_bold = :darkslategray
  when "Uncommon"
    bg = :lightskyblue
    bg_bold = :lightskyblue
    fg_header = :black
  when "Rare"
    bg = :gold
    bg_bold = :goldenrod
    fg_header = :black
  when "Mythic Rare"
    bg = [255, 89, 0]
    bg_bold = :orangered
    fg_header = :black
  else
    bg_bold = :dodgerblue
  end

  return bg, bg_bold, fg_header
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

  return rtnval.color( rarity_colors( rarity )[1] )
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
              complete: ' '.background( :green ).bright,
              incomplete: ' '.background( :white )
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
            "#{c.name} (#{c.source || c.set_name} - #{rarity_label( c.rarity, short_hand: true ).bold})",
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

  bg, bg_bold, fg_header = rarity_colors( card.rarity )

  puts
  puts ' '.background( bg_bold ).bright +
    " #{card.name}".color( fg_header ).background( bg ) +
    (' ' * (width - 2 - card.name.size)).background( bg )
  puts '┃'.color( bg_bold )
  puts '┃ Mana Cost '.color( bg_bold ) + card.mana_cost
  puts '┃ Image URL '.color( bg_bold ) + card.image_url
  puts '┃ Type      '.color( bg_bold ) + card.type
  puts '┃ Rarity    '.color( bg_bold ) + card.rarity.color( bg_bold ).bold
  puts '┃ Set       '.color( bg_bold ) + (card.source || card.set_name)
  puts '┃ P/T       '.color( bg_bold ) + "#{card.power}/#{card.toughness}" if card.types.include?( "Creature" )
  puts '┃ Loyalty   '.color( bg_bold ) + card.loyalty if card.types.include?( "Planeswalker" )

  puts
  puts 'Text'.color( :white ).bold
  puts
  card.text.split( /\n/ ).each_with_index do |text, index|
    puts '┃'.color( :dimgray ) unless index == 0
    text.fit( 60 ).split( /\n/ ).each do |line|
      puts "┃ #{line}".color( :dimgray )
    end
  end

  if card.rulings
    puts
    puts 'Rulings'.color( :white ).bold
    puts
    card.rulings.each_with_index do |ruling, index|
      puts '┃'.color( :dimgray ) unless index == 0
      "#{ruling.date}: #{ruling.text}".fit( 60 ).split( /\n/ ).each do |line|
        puts "┃ #{line}".color( :dimgray )
      end
    end
  end

  puts
  puts 'Metadata'.color( :white ).bold
  puts
  puts '┃ ID                '.color( bg_bold ) + card.id
  puts '┃ Standard Quantity '.color( bg_bold ) + card.standard_quantity.to_s
  puts '┃ Foil Quantity     '.color( bg_bold ) + card.foil_quantity.to_s
end
