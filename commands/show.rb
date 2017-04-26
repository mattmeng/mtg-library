command :show do |c|
  c.action do |gopts, opts, args|
    name = args.join( ' ' )

    if name
      card = get_card( name )

      if card
        puts "#{card.id} - #{card.name} - #{card.standard_quantity}"
      else
        exit_now!( "No cards found." )
      end
    else
      PROMPT.warn( "No card name given." )
    end
  end
end
