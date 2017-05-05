desc 'Get the current status of your library.'
command :status do |c|
  c.action do |gopts, opts, args|
    update_prices
    library_status
  end
end
