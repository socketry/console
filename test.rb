#!/usr/bin/env ruby

require_relative 'lib/console'

begin
	begin
		raise ArgumentError, "it failed"
	rescue => error
		raise RuntimeError, "subsequent error"
	end
rescue => error
	Console.logger.failure(self, error)
end
