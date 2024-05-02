# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2024, by Samuel Williams.
# Copyright, 2021, by Robert Schulze.

require_relative 'generic'

module Console
	module Event
		# Represents a failure event.
		#
		# ```ruby
		# Console::Event::Failure.for(exception).emit(self)
		# ```
		class Failure < Generic
			def self.default_root
				Dir.getwd
			rescue # e.g. Errno::EMFILE
				nil
			end
			
			def self.for(exception)
				self.new(exception, self.default_root)
			end
			
			def self.log(subject, exception, **options)
				Console.error(subject, **self.for(exception).to_hash, **options)
			end
			
			def initialize(exception, root = Dir.getwd)
				@exception = exception
				@root = root
			end
			
			def to_hash
				Hash.new.tap do |hash|
					hash[:type] = :failure
					hash[:root] = @root if @root
					extract(@exception, hash)
				end
			end
			
			def emit(*arguments, **options)
				options[:severity] ||= :error
				
				super
			end
			
			private
			
			def extract(exception, hash)
				hash[:class] = exception.class.name
				
				if exception.respond_to?(:detailed_message)
					message = exception.detailed_message
					
					# We want to remove the trailling exception class as we format it differently:
					message.sub!(/\s*\(.*?\)$/, '')
					
					hash[:message] = message
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
