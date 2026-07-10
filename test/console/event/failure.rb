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

class PlainError
	def class
		StandardError
	end
	
	def message
		"Plain error!"
	end
	
	def backtrace
		[]
	end
	
	def cause
	end
end

describe Console::Event::Failure do
	include Sus::Fixtures::Console::CapturedLogger
	
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
		
		it "logs failures directly" do
			Console::Event::Failure.log("It failed", error, name: "failure")
			
			expect(console_capture.last).to have_keys(
				severity: be == :error,
				subject: be == "It failed",
				name: be == "failure",
			)
		end
		
		it "includes nested causes" do
			begin
				begin
					raise RuntimeError, "Cause!"
				rescue
					raise TestError, "Test error!"
				end
			rescue TestError => error
				expect(Console::Event::Failure.for(error).to_hash).to have_keys(
					cause: have_keys(
						class: be == "RuntimeError",
						message: be =~ /Cause!/
					)
				)
			end
		end
	end
	
	it "returns nil if the default root cannot be determined" do
		expect(Dir).to receive(:getwd).and_raise(Errno::EMFILE)
		
		expect(subject.default_root).to be_nil
	end
	
	it "uses the basic message when detailed messages are unavailable" do
		expect(subject.new(PlainError.new).to_hash).to have_keys(
			message: be == "Plain error!"
		)
	end
end
