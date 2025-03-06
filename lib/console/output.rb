# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require_relative "output/default"
require_relative "output/serialized"
require_relative "output/terminal"
require_relative "output/null"

module Console
	module Output
		# Convert a constant name like `Foo::Bar` to a path like `foo/bar`.
		#
		# @parameter name [String] The constant name.
		# @returns [String] The path.
		def self.to_path(name)
			path = name.gsub("::", "/")
			
			# Insert underscore between acronym and normal words
			path.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
			
			# Insert underscore between lowercase and uppercase letters:
			path.gsub!(/(?<=[a-z0-9])([A-Z])/, '_\1')
			path.downcase!
			
			return path
		end
		
		# Load a constant by name. May require the file if it is not already loaded.
		#
		# @parameter name [String] The constant name.
		# @returns [Class] The constant.
		def self.load(name)
			Output.const_get(name)
		rescue NameError
			begin
				require(to_path(name))
			ensure
				Output.const_get(name)
			end
		end
		
		def self.new(output = nil, env = ENV, **options)
			if names = env["CONSOLE_OUTPUT"]
				names = names.split(",").reverse
				
				names.inject(output) do |output, name|
					load(name).new(output, **options)
				end
			else
				return Output::Default.new(output, **options)
			end
		end
	end
end
