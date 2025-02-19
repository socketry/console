# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024-2025, by Samuel Williams.

require "console/logger"
require "console/capture"

require "console/output/failure"

describe Console::Output::Failure do
	let(:output) {Console::Capture.new}
	let(:logger) {subject.new(output)}
	let(:error) {StandardError.new("Something went wrong")}
	
	it "logs exception messages" do
		logger.call(self, error)
		
		expect(output.last).to have_keys(
			event: have_keys(
				message: be == "Something went wrong"
			)
		)
	end
	
	it "logs exception keyword argument" do
		logger.call(self, exception: error)
		
		expect(output.last).to have_keys(
			event: have_keys(
				message: be == "Something went wrong"
			)
		)
	end
	
	it "logs non-exception exception keyword argument" do
		logger.call(self, exception: "Something went wrong")
		
		expect(output.last).to have_keys(
			exception: be == "Something went wrong"
		)
	end
end
