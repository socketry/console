# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2022, by Samuel Williams.

require_relative 'generic'

module Console
	module Event
		class Spawn < Generic
			def self.for(*arguments, **options)
				# Extract out the command environment:
				if arguments.first.is_a?(Hash)
					environment = arguments.shift
					self.new(environment, arguments, options)
				else
					self.new(nil, arguments, options)
				end
			end
			
			def initialize(environment, arguments, options)
				@environment = environment
				@arguments = arguments
				@options = options
			end
			
			attr :environment
			attr :arguments
			attr :options
			
			def chdir_string(options)
				if options and chdir = options[:chdir]
					" in #{chdir}"
				end
			end
			
			def self.register(terminal)
				terminal[:shell_command] ||= terminal.style(:blue, nil, :bold)
			end
			
			def to_h
				Hash.new.tap do |hash|
					hash[:environment] = @environment if @environment&.any?
					hash[:arguments] = @arguments if @arguments&.any?
					hash[:options] = @options if @options&.any?
				end
			end
			
			def format(output, terminal, verbose)
				arguments = @arguments.flatten.collect(&:to_s)
				
				output.puts "  #{terminal[:shell_command]}#{arguments.join(' ')}#{terminal.reset}#{chdir_string(options)}"
				
				if verbose and @environment
					@environment.each do |key, value|
						output.puts "    export #{key}=#{value}"
					end
				end
			end
		end
	end
	
	# Deprecated.
	Shell = Event::Spawn
end
