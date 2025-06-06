# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "console/event/generic"
require "sus/fixtures/console"

describe Console::Event::Generic do
	include_context Sus::Fixtures::Console::CapturedLogger
	
	with "#to_hash" do
		it "returns an empty hash" do
			event = subject.new
			hash = event.to_hash
			
			expect(hash).to be == {}
		end
	end
	
	with "#as_json" do
		it "returns the same as to_hash" do
			event = subject.new
			
			expect(event.as_json).to be == event.to_hash
		end
	end
	
	with "#to_json" do
		it "returns valid JSON for empty hash" do
			event = subject.new
			json = event.to_json
			
			expect(json).to be_a(String)
			
			parsed = JSON.parse(json)
			expect(parsed).to be == {}
		end
	end
	
	with "#to_s" do
		it "returns JSON representation" do
			event = subject.new
			
			expect(event.to_s).to be == event.to_json
		end
	end
	
	with "#emit" do
		it "can emit without error" do
			event = subject.new
			
			# This should not raise an error (fixes issue #78)
			expect do
				event.emit(self, "foo", severity: :info)
			end.not.to raise_exception
		end
		
		it "logs with generic event structure" do
			event = subject.new
			event.emit(self, "Hello World!", severity: :info)
			
			expect(console_capture.last).to have_keys(
				severity: be == :info,
				subject: be == self,
				arguments: be == ["Hello World!"],
				event: be == {}
			)
		end
		
		it "respects severity option" do
			event = subject.new
			event.emit(self, "Warning message", severity: :warn)
			
			expect(console_capture.last).to have_keys(
				severity: be == :warn,
				subject: be == self,
				arguments: be == ["Warning message"]
			)
		end
		
		it "can emit with multiple arguments" do
			event = subject.new
			event.emit(self, "First", "Second", "Third", severity: :debug)
			
			expect(console_capture.last).to have_keys(
				severity: be == :debug,
				subject: be == self,
				arguments: be == ["First", "Second", "Third"]
			)
		end
	end
end
