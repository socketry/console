# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021, by Samuel Williams.

require_relative 'metric'
require_relative '../clock'

module Console
	module Event
		class Enter < Generic
			def initialize(name)
				@name = name
			end
			
			def format(output, terminal, verbose)
				output.puts "→ #{@name}"
			end
		end
		
		class Exit < Metric
			def value_string
				"← #{@name} took #{Clock.formatted_duration(@value)}"
			end
		end
	end
end
