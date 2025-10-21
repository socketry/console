# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require "sus/fixtures/console"
require "console/warn"

describe "Kernel#warn" do
	include Sus::Fixtures::Console::CapturedLogger
	
	it "redirects to Console.warn" do
		warn "It did not work as expected!"
		
		expect(console_capture.last).to have_keys(
			severity: be == :warn,
			subject: be =~ /It did not work as expected/
		)
	end
end
