# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2022, by Samuel Williams.

require_relative 'event/progress'
require_relative 'clock'

module Console
	class Progress
		def self.now
			Process.clock_gettime(Process::CLOCK_MONOTONIC)
		end
		
		def initialize(output, subject, total = 0, minimum_output_duration: 0.1)
			@output = output
			@subject = subject
			
			@start_time = Progress.now
			
			@last_output_time = nil
			@minimum_output_duration = minimum_output_duration
			
			@current = 0
			@total = total
		end
		
		attr :subject
		attr :current
		attr :total
		
		def duration
			Progress.now - @start_time
		end
		
		def ratio
			Rational(@current.to_f, @total.to_f)
		end
		
		def remaining
			@total - @current
		end
		
		def average_duration
			if @current > 0
				duration / @current
			end
		end
		
		def estimated_remaining_time
			if average_duration = self.average_duration
				average_duration * remaining
			end
		end
		
		def increment(amount = 1)
			@current += amount
			
			if output?
				@output.info(@subject, self) {Event::Progress.new(@current, @total)}
				@last_output_time = Progress.now
			end
			
			return self
		end
		
		def resize(total)
			@total = total
			
			@output.info(@subject, self) {Event::Progress.new(@current, @total)}
			@last_output_time = Progress.now
			
			return self
		end
		
		def mark(...)
			@output.info(@subject, ...)
		end
		
		def to_s
			if estimated_remaining_time = self.estimated_remaining_time
				"#{@current}/#{@total} completed in #{Clock.formatted_duration(self.duration)}, #{Clock.formatted_duration(estimated_remaining_time)} remaining."
			else
				"#{@current}/#{@total} completed, waiting for estimate..."
			end
		end
		
		private
		
		def duration_since_last_output
			if @last_output_time
				Progress.now - @last_output_time
			end
		end
		
		def output?
			if remaining.zero?
				return true
			elsif duration = duration_since_last_output
				return duration > @minimum_output_duration
			else
				return true
			end
		end
	end
end
