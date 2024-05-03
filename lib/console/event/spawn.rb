# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2024, by Samuel Williams.

require_relative 'generic'
require_relative '../clock'

module Console
	module Event
		# Represents a spawn event.
		#
		# ```ruby
		# Console.info(self, **Console::Event::Spawn.for("ls", "-l"))
		#
		# event = Console::Event::Spawn.for("ls", "-l")
		# event.status = Process.wait
		# ```
		class Spawn < Generic
			def self.for(*arguments, **options)
				# Extract out the command environment:
				if arguments.first.is_a?(Hash)
					environment = arguments.shift
					self.new(environment, arguments, options)
				else
					self.new(nil, arguments, options)
				end
			end
			
			def initialize(environment, arguments, options)
				@environment = environment
				@arguments = arguments
				@options = options
				
				@start_time = Clock.now
				
				@end_time = nil
				@status = nil
			end
			
			def duration
				if @end_time
					@end_time - @start_time
				end
			end
			
			def to_hash
				Hash.new.tap do |hash|
					hash[:type] = :spawn
					hash[:environment] = @environment if @environment&.any?
					hash[:arguments] = @arguments if @arguments&.any?
					hash[:options] = @options if @options&.any?
					
					hash[:status] = @status.to_i if @status
					
					if duration = self.duration
						hash[:duration] = duration
					end
				end
			end
			
			def emit(*arguments, **options)
				options[:severity] ||= :info
				super
			end
			
			def status=(status)
				@end_time = Time.now
				@status = status
			end
		end
	end
end
