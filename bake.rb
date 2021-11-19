# frozen_string_literal: true

def sample_progress_bar
	require_relative 'lib/console'
	
	measure = Console.logger.measure("Progress Bar", 10000)
	
	10000.times do |i|
		sleep 0.001
		
		measure.increment
	end
end
