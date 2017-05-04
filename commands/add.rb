desc 'Add new cards to your collection, increasing the quantity.'
command :add do |c|
  c.action do |gopts, opts, args|
    begin
      loop do
        identifier = PROMPT.ask( "Enter card name or ID (ctrl-c to quit):" )

        if identifier && !identifier.empty?
          card = get_card( identifier )

          if card
            add_cards( card )
          else
            PROMPT.error( "No cards found." )
          end
        end
      end
    rescue TTY::Prompt::Reader::InputInterrupt
    end
  end
end
