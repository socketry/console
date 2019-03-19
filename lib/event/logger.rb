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

require_relative 'terminal'
require_relative 'buffer'

require_relative 'shell'
require_relative 'error'

module Event
	class Logger
		LEVELS = {debug: 0, info: 1, warn: 2, error: 3, fatal: 4}
		
		LEVELS.each do |name, level|
			const_set(name.to_s.upcase, level)
			
			define_method(name) do |subject = nil, *arguments, &block|
				enabled = @subjects[subject.class]
				
				if enabled == true or (enabled != false and level >= @level)
					self.format(name, subject, *arguments, &block)
				end
			end
			
			define_method("#{name}!") do
				@level = level
			end
			
			define_method("#{name}?") do
				@level >= level
			end
		end
		
		def initialize(output = $stderr, verbose: true, level: 1)
			@output = output
			@level = level
			@start = Time.now
			
			@verbose = verbose
			@subjects = {}
			
			@terminal = Terminal.new(output)
			@terminal[:logger_prefix] ||= @terminal.style(nil, nil, :bold)
			@terminal[:logger_suffix] ||= @terminal.style(:white, nil, :faint)
			@terminal[:debug] = @terminal.style(:cyan)
			@terminal[:info] = @terminal.style(:green)
			@terminal[:warn] = @terminal.style(:yellow)
			@terminal[:error] = @terminal.style(:red)
			@terminal[:fatal] = @terminal[:error]
			
			Shell.register(@terminal)
			Error.register(@terminal)
		end
		
		attr :level
		attr :verbose
		
		def verbose!
			@verbose = true
		end
		
		def level= value
			if value.is_a? Symbol
				@level = LEVELS[value]
			else
				@level = value
			end
		end
		
		def enabled?(subject)
			@subjects[subject.class] == true
		end
		
		def enable(subject)
			@subjects[subject.class] = true
		end
		
		def disable(subject)
			@subjects[subject.class] = false
		end
		
		def log(level, *arguments, &block)
			unless level.is_a? Symbol
				level = LEVELS[level]
			end
			
			self.send(level, *arguments, &block)
		end
		
		def puts(*args)
			buffer = StringIO.new
			buffer.puts(*args)
			
			@output.write buffer.string
		end
		
		protected
		
		def format(level, subject = nil, *arguments, **specific, &block)
			prefix = time_offset_prefix
			indent = " " * prefix.size
			
			buffer = Buffer.new("#{indent}| ")
			
			if subject
				format_subject(level, prefix, subject, buffer)
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
			
			@output.write buffer.string
		end
		
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
		
		def format_subject(level, prefix, subject, output)
			prefix_style = @terminal[level]
			
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
	end
end
