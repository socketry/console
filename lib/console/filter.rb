# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2024, by Samuel Williams.
# Copyright, 2019, by Bryan Powell.
# Copyright, 2020, by Michael Adams.
# Copyright, 2021, by Robert Schulze.

module Console
	UNKNOWN = :unknown
	
	class Filter
		if Object.const_defined?(:Ractor) and RUBY_VERSION >= '3.1'
			def self.define_immutable_method(name, &block)
				block = Ractor.make_shareable(block)
				self.define_method(name, &block)
			end
		else
			def self.define_immutable_method(name, &block)
				define_method(name, &block)
			end
		end
		
		def self.[] **levels
			klass = Class.new(self)
			minimum_level, maximum_level = levels.values.minmax
			
			klass.instance_exec do
				const_set(:LEVELS, levels.freeze)
				const_set(:MINIMUM_LEVEL, minimum_level)
				const_set(:MAXIMUM_LEVEL, maximum_level)
				
				levels.each do |name, level|
					const_set(name.to_s.upcase, level)
					
					define_immutable_method(name) do |subject = nil, *arguments, **options, &block|
						if self.enabled?(subject, level)
							@output.call(subject, *arguments, severity: name, **@options, **options, &block)
						end
					end
					
					define_immutable_method("#{name}!") do
						@level = level
					end
					
					define_immutable_method("#{name}?") do
						@level <= level
					end
				end
			end
			
			return klass
		end
		
		def initialize(output, verbose: true, level: self.class::DEFAULT_LEVEL, **options)
			@output = output
			@verbose = verbose
			@level = level
			
			@subjects = {}
			
			@options = options
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
		
		def filter(subject, level)
			unless subject.is_a?(Module)
				raise ArgumentError, "Expected a class, got #{subject.inspect}"
			end
			
			@subjects[subject] = level
		end
		
		# You can enable and disable logging for classes. This function checks if logging for a given subject is enabled.
		# @param subject [Object] the subject to check.
		def enabled?(subject, level = self.class::MINIMUM_LEVEL)
			subject = subject.class unless subject.is_a?(Module)
			
			if specific_level = @subjects[subject]
				return level >= specific_level
			end
			
			if level >= @level
				return true
			end
		end
		
		# Enable specific log level for the given class.
		# @parameter name [Module] The class to enable.
		def enable(subject, level = self.class::MINIMUM_LEVEL)
			# Set the filter level of logging for a given subject which passes all log messages:
			filter(subject, level)
		end
		
		def disable(subject)
			# Set the filter level of the logging for a given subject which filters all log messages:
			filter(subject, self.class::MAXIMUM_LEVEL + 1)
		end
		
		# Clear any specific filters for the given class.
		# @parameter name [Module] The class to disable.
		def clear(subject)
			unless subject.is_a?(Module)
				raise ArgumentError, "Expected a class, got #{subject.inspect}"
			end
			
			@subjects.delete(subject)
		end
		
		def call(subject, *arguments, **options, &block)
			severity = options[:severity] || UNKNOWN
			level = self.class::LEVELS[severity]
			
			if self.enabled?(subject, level)
				@output.call(subject, *arguments, **options, &block)
			end
		end
	end
end
