# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2024, by Samuel Williams.

module Console
	module Terminal
		module Formatter
			# Format spawn events.
			class Spawn
				KEY = :spawn
				
				def initialize(terminal)
					@terminal = terminal
					@terminal[:spawn_command] ||= @terminal.style(:blue, nil, :bold)
				end
				
				def format(event, output, verbose: false, width: 80)
					environment, arguments, options = event.values_at(:environment, :arguments, :options)
					
					arguments = arguments.flatten.collect(&:to_s)
					
					output.puts "#{@terminal[:spawn_command]}#{arguments.join(' ')}#{@terminal.reset}#{chdir_string(options)}"
					
					if verbose and environment
						environment.each do |key, value|
							output.puts "export #{key}=#{value}"
						end
					end
				end
				
				private
				
				def chdir_string(options)
					if options and chdir = options[:chdir]
						" in #{chdir}"
					end
				end
			end
		end
	end
end
