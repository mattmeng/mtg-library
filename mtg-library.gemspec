# coding: utf-8
lib = File.expand_path( '../lib', __FILE__ )
$LOAD_PATH.unshift( lib ) unless $LOAD_PATH.include?( lib )
require 'mtg/constants'

Gem::Specification.new do |spec|
  spec.name          = "mtg-library"
  spec.version       = Mtg::VERSION
  spec.authors       = ["Matt Meng"]
  spec.email         = ["mengmatt@gmail.com"]

  spec.summary       = %q{MTG library organizer.}
  spec.description   = %q{MTG library organizer.}
  spec.homepage      = "https://github.com/mattmeng/mtg-library"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match( %r{^(test|spec|features)/} )
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep( %r{^exe/} ) { |f| File.basename( f ) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_dependency "sequel", "~> 4.45"
  spec.add_dependency "mtg_sdk", "~> 3.1"
end
