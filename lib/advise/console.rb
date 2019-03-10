# Copyright, 2019, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

require_relative 'logger'

# Downstream gems often use `Logger:::LEVEL` constants, so we pull this in so they are available. That being said, the code should be fixed.
require 'logger'

module Advise
	module Console
		class << self
			attr :logger
			
			# Set the default log level based on `$DEBUG` and `$VERBOSE`.
			def default_log_level
				if $DEBUG
					Logger::DEBUG
				elsif $VERBOSE
					Logger::INFO
				else
					Logger::WARN
				end
			end
		end
		
		# Create the logger instance.
		@logger = Logger.new($stderr, level: self.default_log_level)
		
		Logger::LEVELS.each do |name, level|
			define_method(name, &@logger.method(name))
		end
		
		def logger
			Console.logger
		end
	end
end