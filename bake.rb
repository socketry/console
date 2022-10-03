# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2022, by Samuel Williams.

def sample_progress_bar
	require_relative 'lib/console'
	
	measure = Console.logger.measure("Progress Bar", 10000)
	
	10000.times do |i|
		sleep 0.001
		
		measure.increment
	end
end
