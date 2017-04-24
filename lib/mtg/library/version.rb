module Mtg
  class Library
    VERSION = File.read( 'version' ).chomp
    ROOT_PATH = File.expand_path( '../../../..', __FILE__ )
    LIB_PATH = File.join( ROOT_PATH, 'lib' )
    MTG_PATH = File.join( LIB_PATH, 'mtg' )
    LIBRARY_PATH = File.join( MTG_PATH, 'library' )
    MIGRATIONS_PATH = File.join( LIBRARY_PATH, 'migrations' )
  end
end
