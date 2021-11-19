# frozen_string_literal: true

module MyModule
	extend Console
	
	def self.argument_error
		raise ArgumentError, "It broken!"
	end
	
	def self.nested_error
		argument_error
	rescue
		raise RuntimeError, "Magic smoke escaped!"
	end
	
	def self.log_error
		self.nested_error
	rescue
		logger.error(self, $!)
	end
	
	def self.test_logger
		logger.debug "1: GOTO LINE 2", "2: GOTO LINE 1"
		
		logger.info "Dear maintainer:" do |buffer|
			buffer.puts "Once you are done trying to 'optimize' this routine, and have realized what a terrible mistake that was, please increment the following counter as a warning to the next guy:"
			buffer.puts "total_hours_wasted_here = 42"
		end
		
		logger.warn "Something didn't work as expected!"
		logger.error "There be the dragons!", (raise RuntimeError, "Bits have been rotated incorrectly!" rescue $!)
		
		logger.info(self) {Console::Shell.for({LDFLAGS: "-lm"}, "gcc", "-o", "stuff.o", "stuff.c", chdir: "/tmp/compile")}
		
		logger.info(Object.new) {"Where would we be without Object.new?"}
	end
	
	test_logger
end
