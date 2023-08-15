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
	
	with SystemStackError do
		let(:frames) {[
			"A",
			"B",
			"C",
			"B",
			"C",
			"D",
			"D",
			"D",
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
			expect(backtrace).to be == [
				"A",
				"B",
				"C",
				"[... 2 frames skipped ...]",
				"D",
				"[... 2 frames skipped ...]",
			]
		end
	end
	
	with StandardError do
		it "can handle as_json raising StandardError" do
			mock(object) do |mock|
				mock.replace(:to_json) do
					raise StandardError, "something went wrong"
				end
			end
			
			message = JSON.parse(
				format.dump(object)
			)
			
			expect(message).to have_keys(
				'truncated' => be == true,
				'error' => have_keys(
					'class' => be == 'StandardError',
					'message' => be =~ /something went wrong/,
				)
			)
			
			backtrace = message['error']['backtrace']
		end
	end
end
