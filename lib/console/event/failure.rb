# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2022, by Samuel Williams.
# Copyright, 2021, by Robert Schulze.

require_relative 'generic'

module Console
	module Event
		class Failure < Generic
			def self.current_working_directory
				Dir.getwd
			rescue # e.g. Errno::EMFILE
				nil
			end
			
			def self.for(exception)
				self.new(exception, self.current_working_directory)
			end
			
			def initialize(exception, root = nil)
				@exception = exception
				@root = root
			end
			
			attr :exception
			attr :root
			
			def self.register(terminal)
				terminal[:exception_title] ||= terminal.style(:red, nil, :bold)
				terminal[:exception_detail] ||= terminal.style(:yellow)
				terminal[:exception_backtrace] ||= terminal.style(:red)
				terminal[:exception_backtrace_other] ||= terminal.style(:red, nil, :faint)
				terminal[:exception_message] ||= terminal.style(:default)
			end
			
			def to_h
				{exception: @exception, root: @root}
			end
			
			def format(output, terminal, verbose)
				format_exception(@exception, nil, output, terminal, verbose)
			end
			
			def format_exception(exception, prefix, output, terminal, verbose)
				lines = exception.message.lines.map(&:chomp)
				
				output.puts "  #{prefix}#{terminal[:exception_title]}#{exception.class}#{terminal.reset}: #{lines.shift}"
				
				lines.each do |line|
					output.puts "  #{terminal[:exception_detail]}#{line}#{terminal.reset}"
				end
				
				root_pattern = /^#{@root}\// if @root
				
				exception.backtrace&.each_with_index do |line, index|
					path, offset, message = line.split(":")
					style = :exception_backtrace
					
					# Make the path a bit more readable
					if root_pattern and path.sub!(root_pattern, "").nil?
						style = :exception_backtrace_other
					end
					
					output.puts "  #{index == 0 ? "→" : " "} #{terminal[style]}#{path}:#{offset}#{terminal[:exception_message]} #{message}#{terminal.reset}"
				end
				
				if exception.cause
					format_exception(exception.cause, "Caused by ", output, terminal, verbose)
				end
			end
		end
	end
end
