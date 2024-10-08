$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your wagon's version:
require "hitobito_sww/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = "hitobito_sww"
  s.version = HitobitoSww::VERSION
  s.authors = ["Nils Rauch"]
  s.email = ["info@hitobito.com"]
  s.homepage = "http://www.hitobito.com"
  s.summary = "SWW organization specific features"
  s.description = "Schweizer Wanderwege specific features"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["Rakefile"]
end
