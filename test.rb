#!/usr/bin/env ruby
# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

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
