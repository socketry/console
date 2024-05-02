# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require_relative 'wrapper'

module Console
	module Output
		class Sensitive < Wrapper
			REDACT = /
				  phone
				| email
				| full_?name
				| first_?name
				| last_?name
				
				| device_name
				| user_agent
				
				| zip
				| address
				| location
				| latitude
				| longitude
				
				| ip
				| gps
				
				| sex
				| gender
				
				| token
				| password
			/xi
			
			def initialize(output, redact: REDACT, **options)
				super(output, **options)
				
				@redact = redact
			end
			
			def redact?(text)
				text.match?(@redact)
			end
			
			def redact_hash(arguments, filter)
				arguments.transform_values do |value|
					redact(value, filter)
				end
			end
			
			def redact_array(array, filter)
				array.map do |value|
					redact(value, filter)
				end
			end
			
			def redact(argument, filter)
				case argument
				when String
					if filter
						filter.call(argument)
					elsif redact?(argument)
						"[REDACTED]"
					else
						argument
					end
				when Array
					redact_array(argument, filter)
				when Hash
					redact_hash(argument, filter)
				else
					redact(argument.to_s, filter)
				end
			end
			
			class Filter
				def initialize(substitutions)
					@substitutions = substitutions
					@pattern = Regexp.union(substitutions.keys)
				end
				
				def call(text)
					text.gsub(@pattern, @substitutions)
				end
			end
			
			def call(subject = nil, *arguments, sensitive: true, **options, &block)
				if sensitive
					if sensitive.respond_to?(:call)
						filter = sensitive
					elsif sensitive.is_a?(Hash)
						filter = Filter.new(sensitive)
					end
					
					subject = redact(subject, filter)
					arguments = redact_array(arguments, filter)
				end
				
				super(subject, *arguments, **options)
			end
		end
	end
end
