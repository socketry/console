# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

require 'logger'

module Console
	module Compatible
		class Logger < ::Logger
			class LogDevice
				def initialize(subject, output)
					@subject = subject
					@output = output
				end
				
				def write(message)
					@output.call(@subject, message)
				end
				
				def call(*arguments, **options)
					@output.call(*arguments, **options)
				end
				
				def reopen
				end
				
				def close
				end
			end

			def initialize(subject, output)
				super(nil)
				
				@progname = subject
				@logdev = LogDevice.new(subject, output)
			end
			
			def add(level, message = nil, progname = nil)
				level ||= UNKNOWN
				
				if @logdev.nil? or level < level
					return true
				end
				
				if progname.nil?
					progname = @progname
				end
				
				if message.nil?
					if block_given?
						message = yield
					else
						message = progname
						progname = @progname
					end
				end
				
				@logdev.call(
					progname, message,
					level: format_level(level)
				)
				
				return true
			end
			
			def format_level(value)
				format_severity(value).downcase.to_sym
			end
		end
	end
end
