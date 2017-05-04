desc 'Add a card to your collection, increasing the quantity.'
command :add do |c|
  c.action do |gopts, opts, args|
    identifier = args.join( ' ' )

    if identifier
      card = get_card( identifier )

      if card
        display_card( card )
      else
        exit_now!( Paint["No cards found.", :red] )
      end
    else
      PROMPT.warn( "No card id or name given." )
    end
  end
end
