# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2025, by Samuel Williams.

require "console/compatible/logger"
require "console/output/terminal"

describe Console::Compatible::Logger do
	let(:stream) {StringIO.new}
	let(:output) {Console::Output::Terminal.new(stream)}
	let(:logger) {Console::Compatible::Logger.new("Test", output)}
	
	it "should log messages" do
		logger.info("Hello World")
		
		expect(stream.string).to be(:include?, "Hello World")
	end
	
	it "formats lower case severity string" do
		expect(logger.format_severity(1)).to be == :info
	end
	
	it "can write a message" do
		logger << "Hello World"
		
		expect(stream.string).to be(:include?, "Hello World")
	end
	
	it "can override progname" do
		logger.add(Logger::INFO, "Hello World")
		
		expect(stream.string).to be(:include?, "Hello World")
	end
	
	it "can generate message from block" do
		logger.info{"Hello World"}
		
		expect(stream.string).to be(:include?, "Hello World")
	end
	
	it "has a default log level" do
		expect(logger.level).to be_a(Integer)
		expect(logger.level).to be == ::Logger::DEBUG
	end
end
