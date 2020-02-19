# frozen_string_literal: true

def console
	require_relative '../lib/console'
end

# Increase the verbosity of the logger to info.
def info
	self.console
	
	Console.logger.info!
end

# Increase the verbosity of the logger to debug.
def debug
	self.console
	
	Console.logger.debug!
end
