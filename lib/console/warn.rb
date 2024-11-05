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
			return super if fiber.console_warn
			
			if uplevel
				options[:backtrace] = caller(uplevel, 1)
			end
			
			begin
				fiber.console_warn = true
				Console.warn(*arguments, **options)
			ensure
				fiber.console_warn = false
			end
		end
	end
	
	::Kernel.prepend(Warn)
end
