# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2025, by Samuel Williams.

require "console/output/terminal"
require "console/event/spawn"

describe Console::Output::Terminal do
	let(:stream) {StringIO.new}
	let(:logger) {subject.new(stream, verbose: true)}
	
	let(:message) {"Hello World"}
	
	with ".start_at!" do
		it "initializes the start time" do
			env = {}
			start_at = subject.start_at!(env)
			
			expect(start_at).to be_a(Time)
			expect(env).to have_keys(
				Console::Output::Terminal::CONSOLE_START_AT => be == start_at.to_s
			)
		end
	end
	
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
	
	it "can log zero arity blocks" do
		logger.call{message}
		
		expect(stream.string).to be(:include?, message)
	end
	
	it "can update verbose mode" do
		logger.verbose!(false)
		
		expect(logger.verbose).to be == false
	end
	
	it "can log module subjects" do
		logger.call(Console::Output::Terminal, message)
		
		expect(stream.string).to be(:include?, "Console::Output::Terminal")
	end
	
	it "can log object subjects with object id" do
		object = Object.new
		logger.call(object, message)
		
		expect(stream.string).to be(:include?, "[oid=0x#{object.object_id.to_s(16)}]")
	end
	
	it "can format registered events" do
		logger.call("command", event: Console::Event::Spawn.for("ls"))
		
		expect(stream.string).to be(:include?, "ls")
	end
	
	it "can format unknown events" do
		event = Object.new
		
		def event.to_hash
			{type: :unknown, value: 10}
		end
		
		logger.call("event", event: event)
		
		expect(stream.string).to be =~ /"value": 10/
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
