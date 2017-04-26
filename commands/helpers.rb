def screen( lines )
  yield
  print CURSOR.clear_lines( lines + 1, :up )
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
            "#{c.name} (#{c.info.source || c.info.set_name})",
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

  case card.rarity
  when "Uncommon"
    bg_bright = :darkslategray
  when "Common"
    bg_bright = :lightskyblue
  when "Rare"
    bg_bright = :gold
  when "Mythic Rare"
    bg = [255, 89, 0]
    bg_bright = [255, 69, 0]
    fg = :black
  else
    bg_bright = :dodgerblue
  end

  puts ' '.background( bg_bright ).bright +
    "  #{card.name}".color( fg ).background( bg ) +
    (' ' * (width - 3 - card.name.size)).background( bg )
end
