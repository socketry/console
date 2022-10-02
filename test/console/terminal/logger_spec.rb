# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2021, by Samuel Williams.

require 'console/terminal/logger'

RSpec.describe Console::Terminal::Logger do
	let(:io) {StringIO.new}
	subject{described_class.new(io)}
	
	let(:message) {"Hello World"}
	
	it "can log to buffer" do
		subject.call do |buffer|
			buffer << message
		end
		
		expect(io.string).to include message
	end
end
