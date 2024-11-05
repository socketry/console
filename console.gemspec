# frozen_string_literal: true

require_relative "lib/console/version"

Gem::Specification.new do |spec|
	spec.name = "console"
	spec.version = Console::VERSION
	
	spec.summary = "Beautiful logging for Ruby."
	spec.authors = ["Samuel Williams", "Robert Schulze", "Bryan Powell", "Michael Adams", "Anton Sozontov", "Cyril Roelandt", "Cédric Boutillier", "Felix Yan", "Olle Jonsson", "Patrik Wenger", "William T. Nelson"]
	spec.license = "MIT"
	
	spec.cert_chain  = ["release.cert"]
	spec.signing_key = File.expand_path("~/.gem/release.pem")
	
	spec.homepage = "https://socketry.github.io/console"
	
	spec.metadata = {
		"documentation_uri" => "https://socketry.github.io/console/",
	}
	
	spec.files = Dir.glob(["{bake,lib}/**/*", "*.md"], File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = ">= 3.1"
	
	spec.add_dependency "fiber-annotation"
	spec.add_dependency "fiber-local", "~> 1.1"
	spec.add_dependency "json"
end
