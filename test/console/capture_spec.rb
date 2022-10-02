# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2021, by Samuel Williams.

require 'console/capture'

RSpec.describe Console::Capture do
	subject {described_class.new}
	let(:logger) {Console::Logger.new(subject)}
	
	describe '#buffer' do
		it 'can access log buffer' do
			logger.info("Hello World!")
			
			last = subject.last
			expect(last).to include(severity: :info, subject: "Hello World!")
		end
	end
end
