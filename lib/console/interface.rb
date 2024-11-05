# frozen_string_literal: true

# Released under the MIT License.
# Copyright 2024, by Samuel Williams.

require_relative "logger"

module Console
	# The public logger interface.
	module Interface
		# Get the current logger instance.
		def logger
			Logger.instance
		end
		
		# Set the current logger instance.
		#
		# The current logger instance is assigned per-fiber.
		def logger= instance
			Logger.instance= instance
		end
		
		# Emit a debug log message.
		def debug(...)
			Logger.instance.debug(...)
		end
		
		# Emit an informational log message.
		def info(...)
			Logger.instance.info(...)
		end
		
		# Emit a warning log message.
		def warn(...)
			Logger.instance.warn(...)
		end
		
		# Emit an error log message.
		def error(...)
			Logger.instance.error(...)
		end
		
		# Emit a fatal log message.
		def fatal(...)
			Logger.instance.fatal(...)
		end
		
		# Emit a log message with arbitrary arguments and options.
		def call(...)
			Logger.instance.call(...)
		end
	end
end
