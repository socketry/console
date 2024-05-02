# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2024, by Samuel Williams.

module Console
	module Output
		class Split
			def self.[](*outputs)
				self.new(outputs)
			end
			
			def initialize(outputs)
				@outputs = outputs
			end
			
			def verbose!(value = true)
				@outputs.each{|output| output.verbose!(value)}
			end
			
			def call(...)
				@outputs.each do |output|
					output.call(...)
				end
			end
		end
	end
end
