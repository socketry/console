# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2023, by Samuel Williams.

source "https://rubygems.org"

# Specify your gem's dependencies in console.gemspec
gemspec

group :maintenance, optional: true do
	gem "bake-gem"
	gem "bake-modernize"
	
	gem "bake-github-pages"
	gem "utopia-project"
end

group :test do
	gem "covered", "~> 0.18.1"
	gem "sus", "~> 0.14"
	
	gem "bake-test"
	gem "bake-test-external"
end
