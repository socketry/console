# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2022, by Samuel Williams.

module Console
	module Event
		# Represents a spawn event.
		#
		# ```ruby
		# Console.info(self, **Console::Event::Spawn.for("ls", "-l"))
		# ```
		class Spawn
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
			
			def to_hash
				Hash.new.tap do |hash|
					hash[:event] = :spawn
					hash[:environment] = @environment if @environment&.any?
					hash[:arguments] = @arguments if @arguments&.any?
					hash[:options] = @options if @options&.any?
				end
			end
		end
	end
end
