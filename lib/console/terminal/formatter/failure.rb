# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

module Console
	module Terminal
		module Formatter
			class Failure
				KEY = :failure
				
				def initialize(terminal)
					@terminal = terminal
					
					@terminal[:exception_title] ||= @terminal.style(:red, nil, :bold)
					@terminal[:exception_detail] ||= @terminal.style(:yellow)
					@terminal[:exception_backtrace] ||= @terminal.style(:red)
					@terminal[:exception_backtrace_other] ||= @terminal.style(:red, nil, :faint)
					@terminal[:exception_message] ||= @terminal.style(:default)
				end
				
				def format(event, output, prefix: nil, verbose: false, width: 80)
					title = event[:class]
					message = event[:message]
					backtrace = event[:backtrace]
					root = event[:root]
					
					lines = message.lines.map(&:chomp)
					
					output.puts "  #{prefix}#{@terminal[:exception_title]}#{title}#{@terminal.reset}: #{lines.shift}"
					
					lines.each do |line|
						output.puts "  #{@terminal[:exception_detail]}#{line}#{@terminal.reset}"
					end
					
					root_pattern = /^#{root}\// if root
					
					backtrace&.each_with_index do |line, index|
						path, offset, message = line.split(":", 3)
						style = :exception_backtrace
						
						# Make the path a bit more readable:
						if root_pattern and path.sub!(root_pattern, "").nil?
							style = :exception_backtrace_other
						end
						
						output.puts "  #{index == 0 ? "→" : " "} #{@terminal[style]}#{path}:#{offset}#{@terminal[:exception_message]} #{message}#{@terminal.reset}"
					end
					
					if cause = event[:cause]
						format(cause, output, prefix: "Caused by ", verbose: verbose, width: width)
					end
				end
			end
		end
	end
end
