# frozen_string_literal: true

require_relative "lib/console/version"

Gem::Specification.new do |spec|
	spec.name = "console"
	spec.version = Console::VERSION
	
	spec.summary = "Beautiful logging for Ruby."
	spec.authors = ["Samuel Williams", "Robert Schulze", "Bryan Powell", "Michael Adams", "Patrik Wenger", "William T. Nelson", "Anton Sozontov", "Copilot", "Cyril Roelandt", "Cédric Boutillier", "Felix Yan", "Olle Jonsson", "Shigeru Nakajima", "Yasha Krasnou"]
	spec.license = "MIT"
	
	spec.cert_chain  = ["release.cert"]
	spec.signing_key = File.expand_path("~/.gem/release.pem")
	
	spec.homepage = "https://github.com/socketry/console"
	
	spec.metadata = {
		"documentation_uri" => "https://socketry.github.io/console/",
		"funding_uri" => "https://github.com/sponsors/ioquatix/",
		"source_code_uri" => "https://github.com/socketry/console.git",
	}
	
	spec.files = Dir.glob(["{bake,context,lib}/**/*", "*.md"], File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = ">= 3.3"
	
	spec.add_dependency "fiber-annotation"
	spec.add_dependency "fiber-local", "~> 1.1"
	spec.add_dependency "json"
end
