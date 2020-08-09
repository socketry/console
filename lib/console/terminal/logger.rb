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
require_relative '../event'

require_relative 'text'
require_relative 'xterm'

require 'json'

module Console
	module Terminal
		# This, and all related methods, is considered private.
		CONSOLE_START_AT = 'CONSOLE_START_AT'
		
		# Exports CONSOLE_START which can be used to synchronize the start times of all child processes when they log using delta time.
		def self.start_at!(environment = ENV)
			if time_string = environment[CONSOLE_START_AT]
				start_at = Time.parse(time_string) rescue nil
			end
			
			unless start_at
				start_at = Time.now
				environment[CONSOLE_START_AT] = start_at.to_s
			end
			
			return start_at
		end
		
		def self.for(io)
			if io.isatty
				XTerm.new(io)
			else
				Text.new(io)
			end
		end
		
		class Logger
			def initialize(io = $stderr, verbose: nil, start_at: Terminal.start_at!, **options)
				@io = io
				@start_at = start_at
				
				@terminal = Terminal.for(io)
				
				if verbose.nil?
					@verbose = !@terminal.colors?
				else
					@verbose = verbose
				end
				
				@terminal[:logger_prefix] ||= @terminal.style(nil, nil, nil)
				@terminal[:logger_suffix] ||= @terminal.style(:white, nil, :faint)
				@terminal[:subject] ||= @terminal.style(nil, nil, :bold)
				@terminal[:debug] = @terminal.style(:cyan)
				@terminal[:info] = @terminal.style(:green)
				@terminal[:warn] = @terminal.style(:yellow)
				@terminal[:error] = @terminal.style(:red)
				@terminal[:fatal] = @terminal[:error]
				
				self.register_defaults(@terminal)
			end
			
			attr :io
			
			attr_accessor :verbose
			
			attr :start
			attr :terminal
			
			def verbose!(value = true)
				@verbose = value
			end
			
			def register_defaults(terminal)
				Event.constants.each do |constant|
					klass = Event.const_get(constant)
					klass.register(terminal)
				end
			end
			
			UNKNOWN = 'unknown'
			
			def call(subject = nil, *arguments, name: nil, severity: UNKNOWN, **options, &block)
				prefix = build_prefix(name || severity.to_s)
				indent = " " * prefix.size
				
				buffer = Buffer.new("#{indent}| ")
				
				if subject
					format_subject(severity, prefix, subject, buffer)
				end
				
				if options&.any?
					format_options(options, buffer)
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
			
			def format_options(options, output)
				format_value(options.to_json, output)
			end
			
			def format_argument(argument, output)
				case argument
				when Exception
					Event::Failure.new(argument).format(output, @terminal, @verbose)
				when Event::Generic
					argument.format(output, @terminal, @verbose)
				else
					format_value(argument, output)
				end
			end
			
			def format_subject(severity, prefix, subject, buffer)
				if subject.is_a?(String)
					format_string_subject(severity, prefix, subject, buffer)
				elsif subject.is_a?(Module)
					format_string_subject(severity, prefix, subject.to_s, buffer)
				else
					format_object_subject(severity, prefix, subject, buffer)
				end
			end
			
			def format_object_subject(severity, prefix, subject, output)
				prefix_style = @terminal[severity]
				
				if @verbose
					suffix = " #{@terminal[:logger_suffix]}[oid=0x#{subject.object_id.to_s(16)}] [pid=#{Process.pid}] [#{Time.now}]#{@terminal.reset}"
				end
				
				prefix = "#{prefix_style}#{prefix}:#{@terminal.reset} "
				
				output.puts "#{@terminal[:subject]}#{subject.class}#{@terminal.reset}#{suffix}", prefix: prefix
			end
			
			def format_string_subject(severity, prefix, subject, output)
				prefix_style = @terminal[severity]
				
				if @verbose
					suffix = " #{@terminal[:logger_suffix]}[pid=#{Process.pid}] [#{Time.now}]#{@terminal.reset}"
				end
				
				prefix = "#{prefix_style}#{prefix}:#{@terminal.reset} "
				
				output.puts "#{@terminal[:subject]}#{subject}#{@terminal.reset}#{suffix}", prefix: prefix
			end
			
			def format_value(value, output)
				string = value.to_s
				
				string.each_line do |line|
					output.puts "#{line}"
				end
			end
			
			def time_offset_prefix
				offset = Time.now - @start_at
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
					"#{time_offset_prefix} #{name.rjust(8)}"
				else
					time_offset_prefix
				end
			end
		end
	end
end
