# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

require 'console/logger'
require 'console/capture'

describe Console::Output::Default do
	let(:output) {Console::Capture.new}
	let(:logger) {subject.new(output)}
	
	def final_output(output)
		if output.respond_to?(:output)
			final_output(output.output)
		else
			output
		end
	end
	
	with 'unspecified output' do
		let(:output) {nil}
		
		it 'should output to $stderr by default' do
			expect(final_output(logger).io).to be == $stderr
		end
	end
end
