# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require_relative 'terminal'
require_relative 'serialized'

module Console
	module Output
		module Default
			def self.new(output, **options)
				output ||= $stderr
				
				if output.tty?
					Terminal.new(output, **options)
				else
					Serialized.new(output, **options)
				end
			end
		end
	end
end
