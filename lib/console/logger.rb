# Copyright, 2017, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

require_relative 'filter'
require_relative 'progress'

require_relative 'resolver'
require_relative 'terminal/logger'
require_relative 'serialized/logger'

require 'fiber/local'

module Console
	class Logger < Filter[debug: 0, info: 1, warn: 2, error: 3, fatal: 4]
		extend Fiber::Local
		
		# Set the default log level based on `$DEBUG` and `$VERBOSE`.
		# You can also specify CONSOLE_LEVEL=debug or CONSOLE_LEVEL=info in environment.
		# https://mislav.net/2011/06/ruby-verbose-mode/ has more details about how it all fits together.
		def self.default_log_level(env = ENV)
			if level = (env['CONSOLE_LEVEL'] || env['CONSOLE_LOG_LEVEL'])
				LEVELS[level.to_sym] || level.to_i
			elsif $DEBUG
				DEBUG
			elsif $VERBOSE.nil?
				WARN
			else
				INFO
			end
		end

		def self.default_output(env = ENV)
			output = env['CONSOLE_OUTPUT']
			case output&.upcase
			when '-', 'STDOUT'
				$stdout
			when 'STDERR', nil
				$stderr
			end
		end

		def self.default_terminal(output = nil, env = ENV, verbose: self.verbose?)
			logger = nil
			format = env['CONSOLE_FORMAT']
			output ||= default_output(env)

			case format&.upcase
			when nil
				logger = Terminal::Logger.new(output, verbose: verbose)
			when 'XTERM'
				logger = Terminal::Logger.new(output, verbose: verbose, format: Terminal::XTerm)
			when 'TEXT', 'TERM'
				logger = Terminal::Logger.new(output, verbose: verbose, format: Terminal::Text)
			else
				Resolver.new.bind([format]) do |klass|
					logger = Serialized::Logger.new(output, format: klass)
				end
			end

			raise "No format found for #{format}" unless logger

			logger
		end
		
		# Controls verbose output using `$VERBOSE`.
		def self.verbose?(env = ENV)
			!$VERBOSE.nil? || env['CONSOLE_VERBOSE']
		end
		
		def self.default_logger(output = self.default_output, terminal: nil, verbose: self.verbose?, level: self.default_log_level)
			terminal ||= self.default_terminal(output, verbose: verbose)
			
			logger = self.new(terminal, verbose: verbose, level: level)
			Resolver.default_resolver(logger)
			
			return logger
		end
		
		def self.local
			self.default_logger($stderr)
		end
		
		DEFAULT_LEVEL = 1
		
		def initialize(output, **options)
			super(output, **options)
		end
		
		def progress(subject, total, **options)
			Progress.new(self, subject, total, **options)
		end
		
		# @deprecated Please use {progress}.
		alias measure progress
		
		def failure(subject, exception, *arguments, &block)
			fatal(subject, *arguments, Event::Failure.new(exception), &block)
		end
	end
end
