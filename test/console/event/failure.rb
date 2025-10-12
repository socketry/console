# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021, by Robert Schulze.
# Copyright, 2021-2025, by Samuel Williams.
# Copyright, 2024, by Patrik Wenger.

require "console/event/failure"
require "sus/fixtures/console"

class TestError < StandardError
	def detailed_message(...)
		"#{message}\nwith details"
	end
end

describe Console::Event::Failure do
	include_context Sus::Fixtures::Console::CapturedLogger
	
	with "test error" do
		let(:error) do
			begin
				raise TestError, "Test error!"
			rescue TestError => error
				error
			end
		end
		
		it "includes detailed message" do
			skip_unless_method_defined(:detailed_message, Exception)
			
			expect(error.detailed_message).to be =~ /with details/
			
			event = Console::Event::Failure.new(error)
			
			expect(event.to_hash).to have_keys(
				message: be =~ /Test error!\nwith details/
			)
		end
		
		it "logs error message" do
			Console::Event::Failure.for(error).emit(self)
			
			expect(console_capture.last).to have_keys(
				severity: be == :error,
				subject: be == self,
				event: have_keys(
					type: be == :failure,
					root: be_a(String),
					class: be =~ /TestError/,
					message: be =~ /Test error!/,
					backtrace: be_a(Array),
				)
			)
		end
		
		it "can get #exception" do
			failure = Console::Event::Failure.for(error)
			
			expect(failure.exception).to be == error
		end
	end
end
