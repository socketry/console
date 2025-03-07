# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require "console/logger"
require "console/capture"

describe Console::Output::Default do
	let(:stream) {nil}
	let(:output) {subject.new(stream)}
	
	it "should output to $stderr by default" do
		expect(output.last_output.stream).to be == $stderr
	end
end
