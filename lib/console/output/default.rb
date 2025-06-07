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
			# @parameter env [Hash] Environment variables (defaults to ENV for testing).
			# @parameter options [Hash] Additional options to customize the output.
			# @returns [Console::Output::Terminal | Console::Output::Serialized] The output instance, depending on whether the `io` is a terminal or not.
			def self.new(stream, env: ENV, **options)
				stream ||= $stderr
				
				if stream.tty? || mail?(env)
					output = Terminal.new(stream, **options)
				else
					output = Serialized.new(stream, **options)
				end
				
				return output
			end
			
			private
			
			# Detect if we're running in a cron job or mail context where human-readable output is preferred.
			# Cron jobs often have MAILTO set and lack TERM, or have minimal TERM values.
			def self.mail?(env = ENV)
				# Check for common cron environment indicators
				return true if env.key?("MAILTO") && !env["MAILTO"].empty?
				
				false
			end
		end
	end
end
