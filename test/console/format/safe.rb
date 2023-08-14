# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

require 'console/logger'
require 'console/capture'
require 'my_custom_output'

class JSONHash < Hash
	def to_json(options = nil)
		::JSON.generate(self)
	end
end

describe Console::Format::Safe do
	let(:format) {subject.new}
	let(:object) {JSONHash.new}
	let(:frames) {[
		"frame 0",
		"frame 1",
		"frame 2",
		"frame 3",
		"frame 2",
		"frame 3",
		"frame 2",
		"frame 3",
		"frame 4",
		"frame 5",
		"frame 6",
		"frame 7",
		"frame 8",
		"frame 9",
	]}
	
	it "can handle as_json raising SystemStackError" do
		mock(object) do |mock|
			mock.replace(:to_json) do
				raise SystemStackError, "stack level too deep", frames
			end
		end
		
		message = JSON.parse(
			format.dump(object)
		)
		
		expect(message).to have_keys(
			'truncated' => be == true,
			'error' => have_keys(
				'class' => be == 'SystemStackError',
				'message' => be =~ /stack level too deep/,
			)
		)
		
		backtrace = message['error']['backtrace']
		expect(backtrace).to be_a(Array)
		expect(frames).to have_attributes(size: be == 10)
	end
end
