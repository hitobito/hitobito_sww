$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your wagon's version:
require 'hitobito_sww/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  # rubocop:disable SingleSpaceBeforeFirstArg
  s.name        = 'hitobito_sww'
  s.version     = HitobitoSww::VERSION
  s.authors     = ['Nils Rauch']
  s.email       = ['info@hitobito.com']
  s.homepage    = 'http://www.hitobito.com'
  s.summary     = 'SWW organization specific features'
  s.description = 'Schweizer Wanderwege specific features'


  s.files = Dir['{app,config,db,lib}/**/*'] + ['Rakefile']
  s.test_files = Dir['test/**/*']
  # rubocop:enable SingleSpaceBeforeFirstArg
end
