# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2022, by Samuel Williams.

def sample_progress_bar
	require_relative 'lib/console'
	
	progress = Console.logger.progress("Progress Bar", 10)
	
	10.times do |i|
		sleep 1
		
		progress.increment
	end
end
