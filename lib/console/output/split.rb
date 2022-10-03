# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2022, by Samuel Williams.

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
			
			def call(level, subject = nil, *arguments, **options, &block)
				@outputs.each do |output|
					output.call(level, subject, *arguments, **options, &block)
				end
			end
		end
	end
end
