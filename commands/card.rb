desc 'Show card details including card data, text, rulings and metadata.'
command :card do |c|
  c.action do |gopts, opts, args|
    identifier = args.join( ' ' )

    if identifier
      card = get_card( identifier )

      if card
        display_card( card )
        choice = PROMPT.expand( 'Options:', [
          {key: 'a', name: 'Add cards', value: :add},
          {key: 'r', name: 'Remove cards', value: :remove},
          {key: 'q', name: 'Quit', value: :quit}
        ], default: 3 )

        case choice
        when :add
          add_cards( card )
        when :remove
          remove_cards( card )
        end
      else
        exit_now!( Paint["No cards found.", :red] )
      end
    else
      PROMPT.warn( "No card id or name given." )
    end
  end
end
