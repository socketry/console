# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require "sus/fixtures/console"

describe "Kernel#warn" do
	include_context Sus::Fixtures::Console::CapturedLogger
	
	it "redirects to Console.warn" do
		warn "It did not work as expected!"
		
		expect(console_capture.last).to have_keys(
			severity: be == :warn,
			subject: be == "It did not work as expected!"
		)
	end
	
	with "uplevel" do
		def print_warning
			warn "It did not work as expected!", uplevel: 0
		end
		
		it "includes appropriate backtrace" do
			print_warning
			
			expect(console_capture.last).to have_keys(
				severity: be == :warn,
				subject: be == "It did not work as expected!",
				backtrace: be_a(Array)
			)
			
			expect(console_capture.last[:backtrace].first).to be =~ /print_warning/
		end
	end
	
	it "supports exceptions" do
		warn "An error occured:", StandardError.new("It did not work as expected!")
		
		expect(console_capture.last).to have_keys(
			severity: be == :warn,
			subject: be == "An error occured:",
			event: have_keys(
				type: be == :failure,
				root: be_a(String),
				class: be =~ /StandardError/,
				message: be =~ /It did not work as expected!/
			)
		)
	end
end
