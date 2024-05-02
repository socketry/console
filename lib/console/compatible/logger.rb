# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2024, by Samuel Williams.

require 'logger'

module Console
	module Compatible
		# A compatible interface for {::Logger} which can be used with {Console}.
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

			def initialize(subject, output = Console)
				super(nil)
				
				@progname = subject
				@logdev = LogDevice.new(subject, output)
			end
			
			def add(severity, message = nil, progname = nil)
				severity ||= UNKNOWN
				
				if @logdev.nil? or severity < level
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
					severity: format_severity(severity)
				)
				
				return true
			end
			
			def format_severity(value)
				super.downcase.to_sym
			end
		end
	end
end
