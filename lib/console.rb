# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2023, by Samuel Williams.
# Copyright, 2019, by Bryan Powell.
# Copyright, 2020, by Michael Adams.
# Copyright, 2021, by Cédric Boutillier.

require_relative 'console/version'
require_relative 'console/logger'

module Console
	class << self
		def logger
			Logger.instance
		end
		
		def logger= instance
			Logger.instance= instance
		end
		
		Logger::LEVELS.each do |name, level|
			define_method(name) do |*arguments, **options, &block|
				Logger.instance.send(name, *arguments, **options, &block)
			end
		end
		
		def call(...)
			Logger.instance.call(...)
		end
	end
	
	def logger= logger
		warn "Setting logger on #{self} is deprecated. Use Console.logger= instead."
	end
	
	def logger
		Logger.instance
	end
end
