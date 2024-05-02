# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require_relative 'output/default'
require_relative 'output/serialized'
require_relative 'output/terminal'
require_relative 'output/null'

module Console
	module Output
		def self.new(output = nil, env = ENV, **options)
			if names = env['CONSOLE_OUTPUT']
				names = names.split(',').reverse
				
				names.inject(output) do |output, name|
					Output.const_get(name).new(output, **options)
				end
			else
				return Output::Default.new(output, **options)
			end
		end
	end
end
