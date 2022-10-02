# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2021, by Samuel Williams.

require 'console'
require 'console/capture'

describe Console::Event::Metric do
	let(:output) {Console::Capture.new}
	let(:logger) {Console::Logger.new(output)}
	let(:event) {subject.new(:x, 10)}
	
	it "can log event" do
		logger.info(self, event)
		
		expect(output.last).to have_keys(
			arguments: be == [event],
		)
	end
end
