# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2022, by Samuel Williams.
# Copyright, 2019, by Bryan Powell.
# Copyright, 2020, by Michael Adams.
# Copyright, 2021, by Cédric Boutillier.

require_relative 'console/version'
require_relative 'console/logger'

module Console
	def self.logger
		Logger.instance
	end
	
	def self.logger= instance
		Logger.instance= instance
	end
	
	def logger= logger
		@logger = logger
	end
	
	def logger
		@logger || Logger.instance
	end
	
	def self.extended(klass)
		klass.instance_variable_set(:@logger, nil)
	end
end
