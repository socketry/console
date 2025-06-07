# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2025, by Samuel Williams.

require "console/logger"
require "console/capture"

describe Console::Output::Default do
	let(:stream) {nil}
	let(:output) {subject.new(stream)}
	
	it "should output to $stderr by default" do
		expect(output.last_output.stream).to be == $stderr
	end
	
	with "output format selection" do
		let(:stream) do
			Object.new.tap do |object|
				def object.tty?
					false
				end
			end
		end
		
		it "should use Terminal output when MAILTO is set" do
			output = subject.new(stream, env: {"MAILTO" => "admin@example.com"})
			expect(output).to be_a(Console::Output::Terminal)
		end
		
		it "should use Serialized output for regular non-TTY streams" do
			output = subject.new(stream, env: {"TERM" => "xterm-256color", "DISPLAY" => ":0"})
			expect(output).to be_a(Console::Output::Serialized)
		end
	end
end
