# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

require_relative '../terminal/logger'

module Console
	module Output
		module XTerm
			def self.new(output, **options)
				Terminal::Logger.new(output, format: Terminal::XTerm, **options)
			end
		end
	end
end
