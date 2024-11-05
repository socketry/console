# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

module Console
	# Whether the current fiber is emitting a warning.
	Fiber.attr_accessor :console_warn
	
	module Warn
		def warn(*arguments, uplevel: nil, **options)
			fiber = Fiber.current
			
			# We do this to be extra pendantic about avoiding infinite recursion, i.e. if `Console.warn` some how calls `Kernel.warn` again, it would potentially cause infinite recursion. I'm not sure if this is a problem in practice, but I'd rather not find out the hard way...
			return if fiber.console_warn
			
			if uplevel
				# Add one to uplevel to skip the current frame.
				options[:backtrace] = caller(uplevel+1, 1)
			end
			
			if arguments.last.is_a?(Exception)
				exception = arguments.pop
				
				Console::Event::Failure.for(exception).emit(*arguments, severity: :warn)
			else
				begin
					fiber.console_warn = true
					Console.warn(*arguments, **options)
				ensure
					fiber.console_warn = false
				end
			end
		end
	end
	
	::Kernel.prepend(Warn)
end
