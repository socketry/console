# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require 'sus/shared'

module Console
	CapturedOutput = Sus::Shared("captured output") do
		let(:capture) {Console::Capture.new}
		let(:logger) {Console::Logger.new(capture)}
		
		def around
			Fiber.new do
				Console.logger = logger
				super
			end.resume
		end	
	end
end
