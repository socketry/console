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
			
			minutes = duration / 60.0
			
			if minutes < 60.0
				seconds = duration % 60
				return format("%dm%02ds", minutes, seconds)
			end
			
			hours = minutes / 60.0
			
			if hours < 24.0
				minutes = minutes % 60
				return format("%dh%02dm", hours, minutes)
			end
			
			days = hours / 24.0
			
			if days < 100.0
				hours = hours % 24
				return format("%dd%02dh", days, hours)
			end
			
			return format("%dd", days)
		end
		
		# @returns [Time] The current monotonic time.
		def self.now
			::Process.clock_gettime(::Process::CLOCK_MONOTONIC)
		end
	end
end
