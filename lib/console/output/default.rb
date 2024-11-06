# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require_relative "terminal"
require_relative "serialized"
require_relative "failure"

module Console
	module Output
		module Default
			def self.new(output, **options)
				output ||= $stderr
				
				if output.tty?
					output = Terminal.new(output, **options)
				else
					output = Serialized.new(output, **options)
				end
				
				return output
			end
		end
	end
end
