# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

require 'console/logger'
require 'console/capture'

require 'console/output/sensitive'

describe Console::Output::Sensitive do
	let(:output) {Console::Capture.new}
	let(:logger) {subject.new(output)}
	
	it 'logs non-sensitive text' do
		logger.call("Hello World")
		
		expect(output).to be(:include?, "Hello World")
	end
	
	it 'redacts sensitive text' do
		logger.call("first_name: Samuel Williams")
		
		expect(output).not.to be(:include?, "Samuel Williams")
	end
	
	with 'sensitive: false' do
		it 'bypasses redaction' do
			logger.call("first_name: Samuel Williams", sensitive: false)
			
			expect(output).to be(:include?, "Samuel Williams")
		end
	end
	
	with 'sensitive: Hash' do
		it 'filters specific tokens' do
			logger.call("first_name: Samuel Williams", sensitive: {"Samuel Williams" => "[First Name]"})
			
			expect(output).to be(:include?, "[First Name]")
			expect(output).not.to be(:include?, "Samuel Williams")
		end
	end
end
