# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2024, by Samuel Williams.

require "console/output/terminal"

describe Console::Output::Terminal do
	let(:stream) {StringIO.new}
	let(:logger) {subject.new(stream, verbose: true)}
	
	let(:message) {"Hello World"}
	
	it "can log to buffer with block" do
		logger.call do |buffer|
			buffer << message
		end
		
		expect(stream.string).to be(:include?, message)
	end
	
	it "can format options" do
		options = {foo: "bar"}
		
		logger.call("Hello World", **options)
		
		expect(stream.string).to be =~ /"foo": "bar"/
	end
	
	with "verbose: false" do
		let(:logger) {subject.new(stream, verbose: false)}
		
		it "can log to buffer" do
			logger.call(message)
			expect(stream.string).to be(:include?, message)
		end
	end
	
	with "Fiber annotation" do
		it "logs fiber annotations" do
			Fiber.new do
				Fiber.annotate("Running in a fiber.")
				
				logger.call(message)
			end.resume
			
			expect(stream.string).to be(:include?, "Running in a fiber.")
		end
		
		it "logs fiber annotations when it isn't a string" do
			thing = ["Running in a fiber."]
			
			Fiber.new do
				Fiber.annotate(thing)
				
				logger.call(message)
			end.resume
			
			expect(stream.string).to be(:include?, thing.to_s)
		end
	end
end
