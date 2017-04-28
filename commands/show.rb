desc 'Show card details including card data, text, rulings and metadata.'
command :show do |c|
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
