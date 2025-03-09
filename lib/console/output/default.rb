# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2025, by Samuel Williams.

require_relative "terminal"
require_relative "serialized"
require_relative "failure"

module Console
	module Output
		# Default output format selection.
		module Default
			# Create a new output format based on the given stream.
			#
			# @parameter io [IO] The output stream.
			# @parameter options [Hash] Additional options to customize the output.
			# @returns [Console::Output::Terminal | Console::Output::Serialized] The output instance, depending on whether the `io` is a terminal or not.
			def self.new(stream, **options)
				stream ||= $stderr
				
				if stream.tty?
					output = Terminal.new(stream, **options)
				else
					output = Serialized.new(stream, **options)
				end
				
				return output
			end
		end
	end
end
