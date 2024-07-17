# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2024, by Samuel Williams.

require_relative 'filter'

module Console
	# A general sink which captures all events into a buffer.
	class Capture
		def initialize
			@records = []
			@verbose = false
		end
		
		attr :records
		
		# @deprecated Use {#records} instead of {#buffer}.
		alias buffer records
		
		alias to_a records
		
		attr :verbose
		
		def include?(pattern)
			@records.any? do |record|
				record[:subject].to_s&.match?(pattern) or record[:message].to_s&.match?(pattern)
			end
		end
		
		def each(&block)
			@records.each(&block)
		end
		
		include Enumerable
		
		def first
			@records.first
		end
		
		def last
			@records.last
		end
		
		def clear
			@records.clear
		end
		
		def empty?
			@records.empty?
		end
		
		def verbose!(value = true)
			@verbose = value
		end
		
		def verbose?
			@verbose
		end
		
		def call(subject = nil, *arguments, severity: UNKNOWN, event: nil,  **options, &block)
			record = {
				time: ::Time.now.iso8601,
				severity: severity,
				**options,
			}
			
			if subject
				record[:subject] = subject
			end
			
			if event
				record[:event] = event.to_hash
			end
			
			if arguments.any?
				record[:arguments] = arguments
			end
			
			if annotation = Fiber.current.annotation
				record[:annotation] = annotation
			end
			
			if block_given?
				if block.arity.zero?
					record[:message] = yield
				else
					buffer = StringIO.new
					yield buffer
					record[:message] = buffer.string
				end
			else
				record[:message] = arguments.join(" ")
			end
			
			@records << record
		end
	end
end
