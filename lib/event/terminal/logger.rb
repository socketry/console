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

require_relative '../buffer'

require_relative '../shell'
require_relative '../error'

require_relative 'text'
require_relative 'xterm'

module Event
	module Terminal
		def self.for(io)
			if io.isatty
				XTerm.new(io)
			else
				Text.new(io)
			end
		end
		
		class Logger
			def initialize(io = $stderr, verbose: false, **options)
				@io = io
				@verbose = verbose
				@start = Time.now
				
				@terminal = Terminal.for(io)
				@terminal[:logger_prefix] ||= @terminal.style(nil, nil, :bold)
				@terminal[:logger_suffix] ||= @terminal.style(:white, nil, :faint)
				@terminal[:debug] = @terminal.style(:cyan)
				@terminal[:info] = @terminal.style(:green)
				@terminal[:warn] = @terminal.style(:yellow)
				@terminal[:error] = @terminal.style(:red)
				@terminal[:fatal] = @terminal[:error]
				
				self.register_default_events(@terminal)
			end
			
			def register_default_events(terminal)
				Shell.register(terminal)
				Error.register(terminal)
			end
			
			UNKNOWN = 'unknown'
			
			def call(subject = nil, *arguments, name: nil, severity: UNKNOWN, &block)
				prefix = build_prefix(name || severity.to_s)
				indent = " " * prefix.size
				
				buffer = Buffer.new("#{indent}| ")
				
				if subject
					format_subject(severity, prefix, subject, buffer)
				end
				
				arguments.each do |argument|
					format_argument(argument, buffer)
				end
				
				if block_given?
					if block.arity.zero?
						format_argument(yield, buffer)
					else
						yield(buffer, @terminal)
					end
				end
				
				@io.write buffer.string
			end
			
			protected
			
			def format_argument(argument, output)
				case argument
				when Exception
					Error.new(argument).format_event(output, @terminal, @verbose)
				when Generic
					argument.format_event(output, @terminal, @verbose)
				else
					format_value(argument, output)
				end
			end
			
			def format_subject(severity, prefix, subject, output)
				prefix_style = @terminal[severity]
				
				if @verbose
					suffix = " #{@terminal[:logger_suffix]}[pid=#{Process.pid}]#{@terminal.reset}"
				end
				
				output.puts "#{@terminal[:logger_prefix]}#{subject}#{@terminal.reset}#{suffix}", prefix: "#{prefix_style}#{prefix}: "
			end
			
			def format_value(value, output)
				string = value.to_s
				
				string.each_line do |line|
					output.puts "#{line}"
				end
			end
			
			def time_offset_prefix
				offset = Time.now - @start
				minutes = (offset/60).floor
				seconds = (offset - (minutes*60))
				
				if minutes > 0
					"#{minutes}m#{seconds.floor}s"
				else
					"#{seconds.round(2)}s"
				end.rjust(6)
			end
			
			def build_prefix(name)
				if @verbose
					"#{time_offset_prefix} #{name.ljust(8)}"
				else
					time_offset_prefix
				end
			end
		end
	end
end
