# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024-2025, by Samuel Williams.

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
	
	it "records completion status and duration" do
		event = subject.for("ls")
		status = Object.new
		
		def status.to_i
			0
		end
		
		expect(event).to receive(:now).and_return(event.start_time + 1)
		
		event.status = status
		
		expect(event.end_time).to be == event.start_time + 1
		expect(event.status).to be == status
		expect(event.duration).to be == 1
		expect(event.to_hash).to have_keys(
			status: be == 0,
			duration: be == 1
		)
	end
	
	it "uses the monotonic clock for completion time" do
		event = subject.for("ls")
		status = Object.new
		
		def status.to_i
			0
		end
		
		event.status = status
		
		expect(event.duration).to be >= 0
	end
end
