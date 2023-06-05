# frozen_string_literal: true

require_relative "lib/console/version"

Gem::Specification.new do |spec|
	spec.name = "console"
	spec.version = Console::VERSION
	
	spec.summary = "Beautiful logging for Ruby."
	spec.authors = ["Samuel Williams", "Robert Schulze", "Bryan Powell", "Michael Adams", "Cyril Roelandt", "Cédric Boutillier", "Olle Jonsson"]
	spec.license = "MIT"
	
	spec.cert_chain  = ['release.cert']
	spec.signing_key = File.expand_path('~/.gem/release.pem')
	
	spec.homepage = "https://github.com/socketry/console"
	
	spec.files = Dir.glob(['{bake,lib}/**/*', '*.md'], File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = ">= 2.7.3"
	
	spec.add_dependency "fiber-local"
	spec.add_dependency "fiber-annotation"
	
	spec.add_development_dependency "bake"
	spec.add_development_dependency "bake-test"
	spec.add_development_dependency "bake-test-external"
	spec.add_development_dependency "bundler"
	spec.add_development_dependency "covered", "~> 0.18.1"
	spec.add_development_dependency "sus", "~> 0.14"
end
