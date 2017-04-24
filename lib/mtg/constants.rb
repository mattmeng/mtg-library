module Mtg
  VERSION = File.read( 'version' ).chomp
  ROOT_PATH = File.expand_path( '../../..', __FILE__ )
  LIB_PATH = File.join( ROOT_PATH, 'lib' )
  MTG_PATH = File.join( LIB_PATH, 'mtg' )
  MIGRATIONS_PATH = File.join( MTG_PATH, 'migrations' )
  MODELS_PATH = File.join( MTG_PATH, 'models' )
end
