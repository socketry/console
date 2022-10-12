#!/usr/bin/env ruby

# Run this using `systemd-cat bundle exec ./integration.rb`
# This will send logs to datadog using the standard systemd journal.

ENV['TRACES_BACKEND'] ||= 'traces/backend/datadog'
ENV['CONSOLE_OUTPUT'] ||= 'Console::Output::Datadog,Console::Output::Default'

require 'ddtrace'

require 'traces'
require 'console/output/datadog'
require 'console'

# Standard log levels according to syslog:
# Fatal: system is unusable
# Error: error conditions
# Warning: warning conditions
# Informational: informational messages
# Debug: debug-level messages

class Logly
	def call(message)
		Console.logger.debug(self, message, audit: true)
		Console.logger.info(self, message, audit: true)
		
		# A log level suitable for security auditing purposes, i.e. for messages that relate to user activity or security events.
		Console.logger.warn(self, message, audit: true)
		
		# Console.logger.warn(self, message, security: true)
		# Console.logger.warn(self, message, auth: true)
		
		Console.logger.warn(self, message, audit: true)
		Console.logger.error(self, message, audit: true)
		Console.logger.fatal(self, message, audit: true)
	end
	
	Traces::Provider(self) do
		def call(message)
			trace('logly.call') {super}
		end
	end
end

Logly.new.call('Hello, world!')
