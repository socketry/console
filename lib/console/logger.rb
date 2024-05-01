# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2022, by Samuel Williams.
# Copyright, 2021, by Bryan Powell.
# Copyright, 2021, by Robert Schulze.

require_relative 'output'
require_relative 'filter'
require_relative 'event'
require_relative 'resolver'

require 'fiber/storage'

module Console
	class Logger < Filter[debug: 0, info: 1, warn: 2, error: 3, fatal: 4]
		# Set the default log level based on `$DEBUG` and `$VERBOSE`.
		# You can also specify CONSOLE_LEVEL=debug or CONSOLE_LEVEL=info in environment.
		# https://mislav.net/2011/06/ruby-verbose-mode/ has more details about how it all fits together.
		def self.default_log_level(env = ENV)
			if level = env['CONSOLE_LEVEL']
				LEVELS[level.to_sym] || level.to_i
			elsif $DEBUG
				DEBUG
			elsif $VERBOSE.nil?
				WARN
			else
				INFO
			end
		end
		
		# Controls verbose output using `$VERBOSE`.
		def self.verbose?(env = ENV)
			!$VERBOSE.nil? || env['CONSOLE_VERBOSE']
		end
		
		def self.default_logger(output = $stderr, env = ENV, **options)
			if options[:verbose].nil?
				options[:verbose] = self.verbose?(env)
			end
			
			if options[:level].nil?
				options[:level] = self.default_log_level(env)
			end
			
			output = Output.new(output, env, **options)
			logger = self.new(output, **options)
			
			Resolver.default_resolver(logger)
			
			return logger
		end
		
		def self.instance
			Fiber[:console_logger] ||= self.default_logger
		end
		
		def self.instance=(logger)
			Fiber[:console_logger] = logger
		end
		
		DEFAULT_LEVEL = 1
		
		def initialize(output, **options)
			super(output, **options)
		end
		
		def progress(subject, total, **options)
			options[:severity] ||= :info
			
			Event::Progress.new(self, subject, total, **options)
		end
		
		def error(subject, *arguments, **options, &block)
			if self.enabled?(subject, ERROR)
				if arguments.first.is_a?(Exception)
					# It's better to use `failure`.
					exception = arguments.shift
					options.merge!(Event::Failure.for(exception))
				end
				
				self.call(subject, *arguments, severity: :error, **@options, **options, &block)
			end
		end
		
		def failure(subject, exception, *arguments, **options, &block)
			if self.enabled?(subject, ERROR)
				self.call(subject, *arguments, severity: :error, **@options, **options, **Event::Failure.for(exception), &block)
			end
		end
	end
end
