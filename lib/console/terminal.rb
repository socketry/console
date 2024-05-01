# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2023, by Samuel Williams.
# Copyright, 2021, by Robert Schulze.

require_relative 'terminal/text'
require_relative 'terminal/xterm'

require_relative 'terminal/formatter/progress'
require_relative 'terminal/formatter/failure'
require_relative 'terminal/formatter/spawn'

module Console
	module Terminal
		def self.for(io)
			if io.isatty
				XTerm.new(io)
			else
				Text.new(io)
			end
		end
	end
end
