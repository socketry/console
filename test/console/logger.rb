# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2024, by Samuel Williams.
# Copyright, 2019, by Bryan Powell.
# Copyright, 2020, by Michael Adams.
# Copyright, 2021, by Robert Schulze.

require "console/logger"
require "console/capture"

describe Console::Logger do
	let(:output) {Console::Capture.new}
	let(:logger) {subject.new(output)}
	
	let(:message) {"Hello World"}
	
	with ".instance" do
		it "propagates to child thread" do
			Fiber.new do
				logger = Console::Logger.instance
				
				Fiber.new do
					expect(Console::Logger.instance).to be_equal(logger)
				end.resume
			end.resume
		end
	end
	
	with "#with" do
		let(:nested) {logger.with(name: "nested", level: :debug)}
		
		it "should change level" do
			expect(nested.level).to be == 0
		end
		
		it "should change name" do
			expect(nested.options[:name]).to be == "nested"
		end
		
		it "logs message with name" do
			nested.error(message)
			
			expect(output.last).to have_keys(
				name: be == "nested",
				subject: be == message,
			)
		end
	end
	
	with "level" do
		let(:level) {0}
		let(:logger) {subject.new(output, level: level)}
		
		it "should have specified log level" do
			expect(logger.level).to be == level
		end
	end
	
	with "default log level" do
		it "logs info" do
			expect(output).to receive(:call).with(message, severity: :info)
			
			logger.info(message)
		end
		
		it "doesn't log debug" do
			expect(output).not.to receive(:call)
			logger.debug(message)
		end
	end
	
	with "#enable" do
		let(:object) {Object.new}
		
		it "can enable specific subjects" do
			logger.warn!
			
			logger.enable(Object)
			expect(logger).to be(:enabled?, object)
			
			expect(output).to receive(:call).with(object, message, severity: :debug)
			logger.debug(object, message)
		end
	end
	
	Console::Logger::LEVELS.each do |name, level|
		with "log level #{name}", unique: name do
			with "#send" do
				it "can log #{name} messages" do
					expect(output).to receive(:call).with(message, severity: name)
				
					logger.level = level
					logger.send(name, message)
				end
			end
			
			with "#off!" do
				it "doesn't log #{name} messages" do
					logger.off!
					
					expect(output).not.to receive(:call)
					logger.send(name, message)
					expect(logger.send("#{name}?")).to be == false
				end
			end
			
			with "#all!" do
				it "can log #{name} messages" do
					logger.all!
					
					expect(output).to receive(:call).with(message, severity: name)
					logger.send(name, message)
					expect(logger.send("#{name}?")).to be == true
				end
			end
		end
	end
	
	describe ".default_log_level" do
		def before
			@debug = $DEBUG
			@verbose = $VERBOSE
			super
		end
		
		def after(error = nil)
			$DEBUG = @debug
			$VERBOSE = @verbose
			super
		end
		
		it "should set default log level" do
			$DEBUG = false
			$VERBOSE = 0
			
			expect(Console::Logger.default_log_level).to be == Console::Logger::INFO
		end
		
		it "should set default log level based on $DEBUG" do
			$DEBUG = true
			
			expect(Console::Logger.default_log_level).to be == Console::Logger::DEBUG
		end
		
		it "should set default log level based on $VERBOSE" do
			$DEBUG = false
			$VERBOSE = true
			
			expect(Console::Logger.default_log_level).to be == Console::Logger::INFO
		end
		
		it "can get log level from ENV" do
			expect(Console::Logger.default_log_level({"CONSOLE_LEVEL" => "debug"})).to be == Console::Logger::DEBUG
		end
	end
	
	with "Fiber annotation" do
		it "logs fiber annotations" do
			Fiber.new do
				Fiber.annotate("Running in a fiber.")
				
				logger.info(message)
			end.resume
			
			expect(output.last).to have_keys(
				annotation: be == "Running in a fiber.",
				subject: be == "Hello World",
			)
		end
	end
end
