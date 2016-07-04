# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ruboty/line/version'

Gem::Specification.new do |spec|
  spec.name          = "ruboty-line"
  spec.version       = Ruboty::Line::VERSION
  spec.authors       = ["manga_osyo"]
  spec.email         = ["manga.osyo@gmail.com"]

  spec.summary       = %q{LINE adapter for Ruboty.}
  spec.description   = %q{LINE adapter for Ruboty.}
  spec.homepage      = "https://github.com/osyo-manga/gem-ruboty-line"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rack"
  spec.add_dependency "thin"
  spec.add_dependency "rest-client"
  spec.add_dependency "line-bot-api"
  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
