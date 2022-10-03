# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2022, by Samuel Williams.

require 'console/terminal/logger'

describe Console::Terminal::Logger do
	let(:io) {StringIO.new}
	let(:logger) {subject.new(io)}
	
	let(:message) {"Hello World"}
	
	it "can log to buffer" do
		logger.call do |buffer|
			buffer << message
		end
		
		expect(io.string).to be(:include?, message)
	end
end
