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
	
	it "can handle as_json raising SystemStackError" do
		mock(object) do |mock|
			mock.replace(:to_json) do
				raise SystemStackError, "stack level too deep", 32.times.map{|i| "frame #{i}"}
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
		expect(backtrace.size).to be == Console::Format::Safe::MAXIMUM_FRAMES
		inform(backtrace)
	end
end
