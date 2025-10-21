# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require "console/event/spawn"
require "sus/fixtures/console"

describe Console::Event::Spawn do
	include Sus::Fixtures::Console::CapturedLogger
	
	it "logs error message" do
		subject.for({"TERM" => "dumb"}, "ls -lah", chdir: "/").emit(self)
		
		expect(console_capture.last).to have_keys(
			severity: be == :info,
			subject: be == self,
			event: have_keys(
				type: be == :spawn,
				environment: be == {"TERM" => "dumb"},
				arguments: be == ["ls -lah"],
				options: be == {chdir: "/"},
			)
		)
	end
end
