# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in console.gemspec
gemspec

group :maintenance, optional: true do
	gem "bake-gem"
	gem "bake-modernize"
	
	gem "bake-github-pages"
	gem "utopia-project"
end
