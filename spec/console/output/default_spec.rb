# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021, by Samuel Williams.

require 'console/logger'
require 'console/capture'

RSpec.describe Console::Output::Default do
	let(:output) {Console::Capture.new}
	subject{described_class.new(output)}
	
	def final_output(output)
		if output.respond_to?(:output)
			final_output(output.output)
		else
			output
		end
	end
	
	context 'with unspecified output' do
		let(:output) {nil}
		
		it 'should output to $stderr by default' do
			expect(final_output(subject).io).to be $stderr
		end
	end
end
