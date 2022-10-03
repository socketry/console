# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2022, by Samuel Williams.

require 'console/terminal/logger'

describe Console::Terminal::Logger do
	let(:io) {StringIO.new}
	let(:logger) {subject.new(io, verbose: true)}
	
	let(:message) {"Hello World"}
	
	it "can log to buffer with block" do
		logger.call do |buffer|
			buffer << message
		end
		
		expect(io.string).to be(:include?, message)
	end
	
	it "can format options" do
		options = {foo: "bar"}
		
		logger.call("Hello World", **options)
		
		expect(io.string).to be(:include?, JSON.dump(options))
	end
	
	with "verbose: false" do
		let(:logger) {subject.new(io, verbose: false)}
		
		it "can log to buffer" do
			logger.call(message)
			expect(io.string).to be(:include?, message)
		end
	end
end
