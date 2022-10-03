# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2022, by Samuel Williams.
# Copyright, 2019, by Bryan Powell.
# Copyright, 2020, by Michael Adams.
# Copyright, 2021, by Robert Schulze.

require_relative 'buffer'

module Console
	UNKNOWN = 'unknown'
	
	class Filter
		def self.[] **levels
			klass = Class.new(self)
			min_level, max_level = levels.values.minmax
			
			klass.instance_exec do
				const_set(:LEVELS, levels)
				const_set(:MINIMUM_LEVEL, min_level)
				const_set(:MAXIMUM_LEVEL, max_level)
				
				levels.each do |name, level|
					const_set(name.to_s.upcase, level)
					
					define_method(name) do |subject = nil, *arguments, **options, &block|
						if self.enabled?(subject, level)
							self.call(subject, *arguments, severity: name, **options, **@options, &block)
						end
					end
					
					define_method("#{name}!") do
						@level = level
					end
					
					define_method("#{name}?") do
						@level <= level
					end
				end
			end
			
			return klass
		end
		
		def initialize(output, verbose: true, level: self.class::DEFAULT_LEVEL, enabled: nil, **options)
			@output = output
			@verbose = verbose
			@level = level
			
			@subjects = {}
			
			@options = options
			
			if enabled
				enabled.each{|name| enable(name)}
			end
		end
		
		def with(level: @level, verbose: @verbose, **options)
			dup.tap do |logger|
				logger.level = level
				logger.verbose! if verbose
				logger.options = @options.merge(options)
			end
		end
		
		attr_accessor :output
		attr :verbose
		attr :level
		
		attr :subjects
		
		attr_accessor :options
		
		def level= level
			if level.is_a? Symbol
				@level = self.class::LEVELS[level]
			else
				@level = level
			end
		end
		
		def verbose!(value = true)
			@verbose = value
			@output.verbose!(value)
		end
		
		def off!
			@level = self.class::MAXIMUM_LEVEL + 1
		end
		
		def all!
			@level = self.class::MINIMUM_LEVEL - 1
		end
		
		# You can enable and disable logging for classes. This function checks if logging for a given subject is enabled.
		# @param subject [Object] the subject to check.
		def enabled?(subject, level = self.class::MINIMUM_LEVEL)
			if specific_level = @subjects[subject.class]
				return level >= specific_level
			end
			
			if level >= @level
				return true
			end
		end
		
		# Enable specific log level for the given class.
		# @parameter name [Class] The class to enable.
		def enable(subject, level = self.class::MINIMUM_LEVEL)
			unless subject.is_a?(Class)
				raise ArgumentError, "Expected a class, got #{subject.inspect}"
			end
			
			@subjects[subject] = level
		end
		
		# Disable specific logging for the specific class.
		# @parameter name [Class] The class to disable.
		def disable(subject)
			unless subject.is_a?(Class)
				raise ArgumentError, "Expected a class, got #{subject.inspect}"
			end
			
			@subjects.delete(subject)
		end
		
		def call(*arguments, **options, &block)
			@output.call(*arguments, **options, &block)
		end
	end
end
