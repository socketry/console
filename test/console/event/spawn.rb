# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021, by Robert Schulze.
# Copyright, 2021-2024, by Samuel Williams.

require 'console/captured_output'
require 'console/event/spawn'

describe Console::Event::Spawn do
	include_context Console::CapturedOutput
	
	it "logs error message" do
		subject.for({'TERM' => 'dumb'}, "ls -lah", chdir: "/").emit(self)
		
		last = capture.last
		expect(last).to have_keys(
			severity: be == :info,
			subject: be == self,
			event: have_keys(
				type: be == :spawn,
				environment: be == {'TERM' => 'dumb'},
				arguments: be == ["ls -lah"],
				options: be == {chdir: "/"},
			)
		)
	end
end
