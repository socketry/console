# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021, by Samuel Williams.

require 'console/logger'
require 'console/capture'

require 'console/output/sensitive'

RSpec.describe Console::Output::Sensitive do
	let(:output) {Console::Capture.new}
	subject{described_class.new(output)}
	
	it 'logs non-sensitive text' do
		subject.call("Hello World")
		
		expect(output).to include("Hello World")
	end
	
	it 'redacts sensitive text' do
		subject.call("first_name: Samuel Williams")
		
		expect(output).to_not include("Samuel Williams")
	end
	
	context 'with sensitive: false' do
		it 'bypasses redaction' do
			subject.call("first_name: Samuel Williams", sensitive: false)
			
			expect(output).to include("Samuel Williams")
		end
	end
	
	context 'with sensitive: Hash' do
		it 'filters specific tokens' do
			subject.call("first_name: Samuel Williams", sensitive: {"Samuel Williams" => "[First Name]"})
			
			expect(output).to include("[First Name]")
			expect(output).to_not include("Samuel Williams")
		end
	end
end
