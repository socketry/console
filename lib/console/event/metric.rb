# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2021, by Samuel Williams.

require_relative 'generic'
require_relative '../clock'

module Console
	module Event
		class Metric < Generic
			def self.[](**parameters)
				parameters.map(&self.method(:new))
			end
			
			def initialize(name, value, **tags)
				@name = name
				@value = value
				@tags = tags
			end
			
			attr :name
			attr :value
			attr :tags
			
			def to_h
				{name: @name, value: @value, tags: @tags}
			end
			
			def value_string
				"#{@name}: #{@value}"
			end
			
			def format(output, terminal, verbose)
				if @tags&.any?
					output.puts "#{value_string} #{@tags.inspect}"
				else
					output.puts value_string
				end
			end
		end
	end
end
