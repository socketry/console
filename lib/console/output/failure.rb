# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require_relative "wrapper"
require_relative "../event/failure"

module Console
	module Output
		# A wrapper for outputting failure messages, which can include exceptions.
		class Failure < Wrapper
			def initialize(output, **options)
				super(output, **options)
			end
			
			# The exception must be either the last argument or passed as an option.
			def call(subject = nil, *arguments, exception: nil, **options, &block)
				if exception.nil?
					last = arguments.last
					if last.is_a?(Exception)
						options[:event] = Event::Failure.for(last)
					end
				else
					options[:event] = Event::Failure.for(exception)
				end
				
				super(subject, *arguments, **options)
			end
		end
	end
end
