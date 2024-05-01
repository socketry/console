# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

require_relative 'terminal'
require_relative 'serialized'

module Console
	module Output
		module Default
			def self.new(output, io: $stderr, **options)
				if io.tty?
					Terminal.new(io: io, **options)
				else
					Serialized.new(io: io, **options)
				end
			end
		end
	end
end
