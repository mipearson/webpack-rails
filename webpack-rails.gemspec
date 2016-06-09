$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "webpack/rails/react/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "webpack-rails-react"
  s.version     = Webpack::Rails::React::VERSION
  s.authors     = ["Dave Jungst", "Jake Sorce"]
  s.email       = ["dave@cottonwoodcoding.com", "jake@cottonwoodcoding.com"]
  s.homepage    = "https://github.com/cottonwoodcoding/webpack-rails-react"
  s.summary     = "Webpack / Rails / React"
  s.description = "Production-tested, JavaScript-first tooling to use webpack within your Rails application"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib,example}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 3.2.0"
  s.required_ruby_version = '>= 2.0.0'
end
