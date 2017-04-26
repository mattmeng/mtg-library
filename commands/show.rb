command :show do |c|
  c.action do |gopts, opts, args|
    name = args.shift
    spinner = TTY::Spinner.new( ":spinner Searching for cards...", format: :dots, clear: true )
    progress = nil
    cards = []

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
                complete: PASTEL.on_bright_green( ' ' ),
                incomplete: PASTEL.on_white( ' ' )
              )
            end
            progress.advance
          end
        end
      end

      if cards.empty?
        exit_now!( "No cards found." )
      elsif cards.count == 1
        card = cards.first
      else
        card_id = PROMPT.select( "Which card did you mean?", Hash[cards.map {|c| [c.name, c.id]}] )
        card = cards.select {|c| c.id == card_id}.first
      end

      puts "#{card.id} - #{card.name} - #{card.standard_quantity}"
    else
      PROMPT.warn( "No card name given." )
    end
  end
end
