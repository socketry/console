# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2021, by Samuel Williams.

require_relative 'event/measure'
require_relative 'clock'

module Console
	class Measure
		def initialize(output, subject, **tags)
			@output = output
			@subject = subject
			@tags = tags
		end
		
		attr :tags
		
		# Measure the execution of a block of code.
		def duration(name, &block)
			@output.info(@subject) {Event::Enter.new(name)}
			
			start_time = Clock.now
			
			result = yield(self)
			
			duration = Clock.now - start_time
			
			@output.info(@subject) {Event::Exit.new(name, duration, **@tags)}
			
			return result
		end
	end
end
