# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2025, by Samuel Williams.
# Copyright, 2026, by William T. Nelson.

module Console
	# A simple clock utility for tracking and formatting time.
	module Clock
		# Format a duration in seconds as a human readable string.
		#
		# @parameter duration [Numeric] The duration in seconds.
		# @returns [String] The formatted duration.
		def self.formatted_duration(duration)
			if duration < 60.0
				return format("%.2fs", duration)
			end
			
			seconds = duration % 60
			duration /= 60.0
			
			if duration < 60.0
				return format("%dm%02ds", duration, seconds)
			end
			
			minutes = duration % 60
			duration /= 60.0
			
			if duration < 24.0
				return format("%dh%02dm", duration, minutes)
			end
			
			hours = duration % 24
			duration /= 24.0
			
			if duration < 100.0
				return format("%dd%02dh", duration, hours)
			end
			
			return format("%dd", duration)
		end
		
		# @returns [Time] The current monotonic time.
		def self.now
			::Process.clock_gettime(::Process::CLOCK_MONOTONIC)
		end
	end
end
