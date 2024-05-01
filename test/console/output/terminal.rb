# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2023, by Samuel Williams.

require 'console/output/terminal'

describe Console::Output::Terminal do
	let(:io) {StringIO.new}
	let(:logger) {subject.new(io: io, verbose: true)}
	
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
		
		expect(io.string).to be =~ /"foo": "bar"/
	end
	
	with "verbose: false" do
		let(:logger) {subject.new(io, verbose: false)}
		
		it "can log to buffer" do
			logger.call(message)
			expect(io.string).to be(:include?, message)
		end
	end
	
	with "Fiber annotation" do
		it "logs fiber annotations" do
			Fiber.new do
				Fiber.annotate("Running in a fiber.")
				
				logger.call(message)
			end.resume
			
			expect(io.string).to be(:include?, "Running in a fiber.")
		end
		
		it "logs fiber annotations when it isn't a string" do
			thing = ["Running in a fiber."]
			
			Fiber.new do
				Fiber.annotate(thing)
				
				logger.call(message)
			end.resume
			
			expect(io.string).to be(:include?, thing.to_s)
		end
	end
end
