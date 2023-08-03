# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require 'console/output/encoder'
require 'console/capture'

describe Console::Output::Encoder do
	let(:output) {Console::Capture.new}
	let(:encoder) {subject.new(output)}
	
	let(:invalid_string) {"hello \xc3\x28 world"}
	it "is an invalid string" do
		expect(invalid_string).not.to be(:valid_encoding?)
	end
	
	it "can fix encoding" do
		valid_string = encoder.encode(invalid_string)
		expect(valid_string).to be(:valid_encoding?)
	end
	
	it "can encode hashes" do
		invalid = {key: invalid_string}
		valid = encoder.encode(invalid)
		
		expect(valid[:key]).to be(:valid_encoding?)
	end
	
	it "can encode arrays" do
		invalid = [invalid_string]
		valid = encoder.encode(invalid)
		
		expect(valid.first).to be(:valid_encoding?)
	end
	
	it "ignores non-strings" do
		expect(encoder.encode(1)).to be == 1
	end
end
