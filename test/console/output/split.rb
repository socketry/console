# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

require 'console/output/split'
require 'console/capture'

describe Console::Output::Split do
	let(:outputs) {2.times.map{Console::Capture.new}}
	let(:logger) {subject[*outputs]}
	
	it "can log to multiple outputs" do
		logger.call("Hello World!")
		
		expect(outputs[0]).to be(:include?, "Hello World!")
		expect(outputs[1]).to be(:include?, "Hello World!")
	end
	
	it "can assign verbosity to multiple outputs" do
		logger.verbose!(true)
		
		expect(outputs[0].verbose?).to be == true
		expect(outputs[1].verbose?).to be == true
	end
end
