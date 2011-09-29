# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 1.8.7'
  s.required_rubygems_version = ">= 1.3.6"

  s.name        = "preferable"
  s.summary     = "Simple preferences store for ActiveRecord"
  s.description = "Great for storing user preferences"
  s.version     = '0.3.0'

  s.authors     = ["Dimitrij Denissenko", "Evgeniy Dolzhenko"]
  s.email       = "dimitrij@blacksquaremedia.com"
  s.homepage    = "https://github.com/bsm/preferable"

  s.require_path = 'lib'
  s.files        = Dir['README.markdown', 'lib/**/*']

  s.add_dependency "abstract"
  s.add_dependency "activerecord", ">= 3.0.0", "< 3.2.0"
end
