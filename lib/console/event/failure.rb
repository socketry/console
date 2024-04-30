# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2022, by Samuel Williams.
# Copyright, 2021, by Robert Schulze.

module Console
	module Event
		# Represents a failure event.
		#
		# ```ruby
		# Console.error(self, **Console::Event::Failure.for(exception))
		# ````
		class Failure
			def self.default_root
				Dir.getwd
			rescue # e.g. Errno::EMFILE
				nil
			end
			
			def self.for(exception)
				self.new(exception, self.default_root)
			end
			
			def initialize(exception, root)
				@exception = exception
				@root = root
			end
			
			def to_hash
				Hash.new.tap do |hash|
					hash[:event] = :failure
					hash[:root] = @root if @root
					extract(@exception, hash)
				end
			end
			
			private
			
			def extract(exception, hash)
				hash[:title] = exception.class
				
				if exception.respond_to?(:detailed_message)
					hash[:message] = exception.detailed_message
				else
					hash[:message] = exception.message
				end
				
				hash[:backtrace] = exception.backtrace
				
				if cause = exception.cause
					hash[:cause] = Hash.new.tap do |cause_hash|
						extract(cause, cause_hash)
					end
				end
			end
		end
	end
end
