# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2022, by Samuel Williams.

require 'console/capture'

describe Console::Capture do
	let(:capture) {subject.new}
	let(:logger) {Console::Logger.new(capture)}
	
	with '#buffer' do
		it 'can access log buffer' do
			logger.info("Hello World!")
			
			last = capture.last
			expect(last).to have_keys(
				severity: be == :info,
				subject: be == "Hello World!"
			)
		end
	end
end
