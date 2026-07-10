# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "console/output/null"

describe Console::Output::Null do
	let(:output) {subject.new}
	
	it "is its own last output" do
		expect(output.last_output).to be_equal(output)
	end
	
	it "ignores calls" do
		expect(output.call("Hello World")).to be_nil
	end
end
