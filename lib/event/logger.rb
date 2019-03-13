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

require 'pp'

module Event
	class Logger
		LEVELS = {debug: 0, info: 1, warn: 2, error: 3}
		
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
		end
		
		def initialize(output, verbose = true, level: 1)
			@output = output
			@level = level
			@start = Time.now
			
			@verbose = verbose
			
			@terminal = Terminal.new(output)
			
			@level_style = Hash.new{@prefix_style}
			
			@reset_style = @terminal.reset
			@prefix_style = @terminal.color(Terminal::Colors::CYAN)
			@subject_style = @terminal.color(nil, nil, Terminal::Attributes::BOLD)
			@exception_title_style = @terminal.color(Terminal::Colors::RED, nil, Terminal::Attributes::BOLD)
			@exception_details_style = @terminal.color(Terminal::Colors::YELLOW)
			@exception_line_style = @terminal.color(Terminal::Colors::RED)
			
			@level_style[:info] = @terminal.color(Terminal::Colors::GREEN)
			@level_style[:warn] = @terminal.color(Terminal::Colors::YELLOW)
			@level_style[:error] = @terminal.color(Terminal::Colors::RED)
			
			@shell_command = @terminal.color(Terminal::Colors::BLUE, nil, Terminal::Attributes::BOLD)
			
			@subjects = {}
		end
		
		attr :level
		
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
		
		protected
		
		def format(level, subject = nil, *arguments, **specific, &block)
			prefix = time_offset_prefix
			indent = " " * prefix.size
			
			buffer = Buffer.new("#{indent}| ")
			
			if subject
				format_subject(level, prefix, subject, output: buffer)
			end
			
			arguments.each do |argument|
				format_argument(argument, output: buffer)
			end
			
			specific.each do |name, argument|
				self.send("format_#{name}", argument, output: buffer)
			end
			
			if block_given?
				if block.arity.zero?
					format_argument(yield, output: buffer)
				else
					yield(buffer, @terminal)
				end
			end
			
			@output.write buffer.string
		end
		
		def format_argument(argument, output: @output)
			if argument.is_a? Exception
				format_exception(argument, output: output)
			else
				format_value(argument, output: output)
			end
		end
		
		def chdir_string(options)
			if options and chdir = options[:chdir]
				" in #{chdir}"
			end
		end
		
		def format_shell(arguments, output: @output)
			arguments = arguments.dup
			
			environment = arguments.first.is_a?(Hash) ? arguments.shift : nil
			options = arguments.last.is_a?(Hash) ? arguments.pop : nil
			
			arguments = arguments.flatten.collect(&:to_s)
			
			output.puts "#{@shell_command}#{arguments.join(' ')}#{@reset_style}#{chdir_string(options)}"
			
			if @verbose
				if environment
					environment.each do |key, value|
						output.puts "export #{key}=#{value}"
					end
				end
			end
		end
		
		def format_exception(exception, prefix = nil, pwd: Dir.pwd, output: @output)
			lines = exception.message.lines.map(&:chomp)
			
			output.puts "  #{prefix}#{@exception_title_style}#{exception.class}#{@reset_style}: #{lines.shift}"
			
			lines.each do |line|
				output.puts "  #{@exception_details_style}" + line + @reset_style
			end
			
			exception.backtrace&.each_with_index do |line, index|
				path, offset, message = line.split(":")
				
				# Make the path a bit more readable
				path.gsub!(/^#{pwd}\//, "./")
				
				output.puts "  #{index == 0 ? "→" : " "} #{@exception_line_style}#{path}:#{offset}#{@reset_style} #{message}"
			end
			
			if exception.cause
				format_exception(exception.cause, "Caused by ", pwd: pwd, output: output)
			end
		end
		
		def format_subject(level, prefix, subject, output: @output)
			prefix_style = @level_style[level]
			
			if @verbose
				suffix = " [pid=#{Process.pid}]"
			end
			
			output.puts "#{@subject_style}#{subject}#{@reset_style}#{suffix}", prefix: "#{prefix_style}#{prefix}: "
		end
		
		def format_value(value, output: @output)
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
