# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2024, by Samuel Williams.

require 'io/console'

module Console
	# Styled terminal output.
	module Terminal
		class Text
			def initialize(output)
				@output = output
				@styles = {reset: self.reset}
			end
			
			def [] key
				@styles[key]
			end
			
			def []= key, value
				@styles[key] = value
			end
			
			def colors?
				false
			end
			
			def width
				80
			end
			
			def style(foreground, background = nil, *attributes)
			end
			
			def reset
			end
			
			def write(*arguments, style: nil)
				if style and prefix = self[style]
					@output.write(prefix)
					@output.write(*arguments)
					@output.write(self.reset)
				else
					@output.write(*arguments)
				end
			end
			
			def puts(*arguments, style: nil)
				if style and prefix = self[style]
					@output.write(prefix)
					@output.puts(*arguments)
					@output.write(self.reset)
				else
					@output.puts(*arguments)
				end
			end
			
			# Print out the given arguments.
			# When the argument is a symbol, look up the style and inject it into the output stream.
			# When the argument is a proc/lambda, call it with self as the argument.
			# When the argument is anything else, write it directly to the output.
			def print(*arguments)
				arguments.each do |argument|
					case argument
					when Symbol
						@output.write(self[argument])
					when Proc
						argument.call(self)
					else
						@output.write(argument)
					end
				end
			end
			
			# Print out the arguments as per {#print}, followed by the reset sequence and a newline.
			def print_line(*arguments)
				print(*arguments)
				@output.puts(self.reset)
			end
		end
	end
end
