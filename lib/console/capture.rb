# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2024, by Samuel Williams.

require_relative 'filter'

module Console
	# A general sink which captures all events into a buffer.
	class Capture
		def initialize
			@buffer = []
			@verbose = false
		end
		
		attr :buffer
		attr :verbose
		
		def last
			@buffer.last
		end
		
		def include?(pattern)
			JSON.dump(@buffer).include?(pattern)
		end
		
		def clear
			@buffer.clear
		end
		
		def empty?
			@buffer.empty?
		end
		
		def verbose!(value = true)
			@verbose = value
		end
		
		def verbose?
			@verbose
		end
		
		def call(subject = nil, *arguments, severity: UNKNOWN, event: nil,  **options, &block)
			message = {
				time: ::Time.now.iso8601,
				severity: severity,
				**options,
			}
			
			if subject
				message[:subject] = subject
			end
			
			if event
				message[:event] = event.to_hash
			end
			
			if arguments.any?
				message[:arguments] = arguments
			end
			
			if annotation = Fiber.current.annotation
				message[:annotation] = annotation
			end
			
			if block_given?
				if block.arity.zero?
					message[:message] = yield
				else
					buffer = StringIO.new
					yield buffer
					message[:message] = buffer.string
				end
			end
			
			@buffer << message
		end
	end
end
