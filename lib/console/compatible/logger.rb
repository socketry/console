# frozen_string_literal: true

# Copyright, 2021, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

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
				@logdev = LogDevice.new(@subject, output)
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
		end
	end
end
