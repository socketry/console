# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2024, by Samuel Williams.
# Copyright, 2019, by Bryan Powell.
# Copyright, 2020, by Michael Adams.
# Copyright, 2021, by Robert Schulze.

require "console/interface"

describe Console::Interface do
	with ".instance" do
		it "propagates to child thread" do
			Fiber.new do
				logger = Console::Interface.instance
				
				Fiber.new do
					expect(Console::Interface.instance).to be_equal(logger)
				end.resume
			end.resume
		end
	end
end
