# -*- encoding: utf-8 -*-
require File.expand_path('../lib/locu/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Dave Tapley"]
  gem.email         = ["dukedave@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "locu"
  gem.require_paths = ["lib"]
  gem.version       = Locu::Ruby::VERSION

  gem.add_dependency "money"

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "webmock"
  gem.add_development_dependency "vcr"
  gem.add_development_dependency "debugger"
  gem.add_development_dependency "awesome_print"
end

