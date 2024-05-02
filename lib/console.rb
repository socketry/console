# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2024, by Samuel Williams.
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
		
		def debug(...)
			Logger.instance.debug(...)
		end
		
		def info(...)
			Logger.instance.info(...)
		end
		
		def warn(...)
			Logger.instance.warn(...)
		end
		
		def error(...)
			Logger.instance.error(...)
		end
		
		def fatal(...)
			Logger.instance.fatal(...)
		end
		
		def call(...)
			Logger.instance.call(...)
		end
	end
end
