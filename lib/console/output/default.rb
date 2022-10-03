# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

require_relative 'xterm'
require_relative 'json'

module Console
	module Output
		module Default
			def self.new(output, **options)
				output ||= $stderr
				
				if output.tty?
					XTerm.new(output, **options)
				else
					JSON.new(output, **options)
				end
			end
		end
	end
end
