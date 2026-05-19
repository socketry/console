# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2025, by Samuel Williams.
# Copyright, 2026, by Copilot.

require "console/filter"
require "console/logger"
require "console/capture"

module MySubject
end

describe Console::Filter do
	let(:output) {Console::Capture.new}
	let(:logger) {Console::Logger.new(output)}
	
	with "#off!" do
		def before
			super
			logger.off!
		end
		
		it "does not log messages" do
			logger.info(MySubject, "Hello World")
			expect(output).to be(:empty?)
		end
		
		with "#enable" do
			def before
				super
				logger.enable(MySubject)
			end
			
			it "can enable a specific subject" do
				logger.info(MySubject, "Hello World")
				expect(output).to be(:include?, "Hello World")
			end
			
			with "#clear" do
				def before
					super
					logger.clear(MySubject)
				end
				
				it "can clear a specific subject" do
					logger.info(MySubject, "Hello World")
					expect(output).to be(:empty?)
				end
			end
		end
	end
	
	with "#enable" do
		it "can't enable non-class subjects" do
			expect do
				logger.enable("Hello World")
			end.to raise_exception(ArgumentError)
		end
	end
	
	with "#clear" do
		it "can't clear non-class subjects" do
			expect do
				logger.clear("Hello World")
			end.to raise_exception(ArgumentError)
		end
	end
	
	with "#info" do
		it "ignores messages below the level" do
			logger.level = Console::Logger::INFO
			
			result = logger.debug(MySubject, "Hello World")
			
			expect(output).to be(:empty?)
			expect(result).to be_nil
		end
		
		it "logs messages at the level" do
			logger.level = Console::Logger::INFO
			
			result = logger.info(MySubject, "Hello World", severity: :info)
			
			expect(output).to be(:include?, "Hello World")
			expect(result).to be_nil
		end
	end
	
	with "#call" do
		it "ignores messages below the level" do
			logger.level = Console::Logger::INFO
			
			result = logger.call(MySubject, "Hello World", severity: :debug)
			
			expect(output).to be(:empty?)
			expect(result).to be_nil
		end
		
		it "logs messages at the level" do
			logger.level = Console::Logger::INFO
			
			result = logger.call(MySubject, "Hello World", severity: :info)
			
			expect(output).to be(:include?, "Hello World")
			expect(result).to be_nil
		end
		
		it "logs messages above the level" do
			logger.level = Console::Logger::INFO
			
			result = logger.call(MySubject, "Hello World", severity: :warn)
			
			expect(output).to be(:include?, "Hello World")
			expect(result).to be_nil
		end
	end
	
	with "custom filter class" do
		let(:custom_filter) {Console::Filter[noise: 0, stuff: 1, broken: 2]}
		let(:custom_logger) {custom_filter.new(output)}
		
		it "can create a custom filter class" do
			expect(custom_logger).to be_a(Console::Filter)
		end
		
		it "has DEFAULT_LEVEL constant defined" do
			expect(custom_filter::DEFAULT_LEVEL).to be_a(Integer)
		end
		
		it "can log messages" do
			custom_logger.broken(MySubject, "It's so janky")
			expect(output).to be(:include?, "It's so janky")
		end
		
		it "respects log levels" do
			custom_logger.level = custom_filter::BROKEN
			
			custom_logger.noise(MySubject, "This is noise")
			expect(output).to be(:empty?)
			
			custom_logger.broken(MySubject, "This is broken")
			expect(output).to be(:include?, "This is broken")
		end
		
		with "chained with another logger" do
			let(:inner_logger) {Console::Logger.new(output)}
			let(:chained_logger) {custom_filter.new(inner_logger, name: "Chained")}
			
			it "can log through chained loggers with different severities" do
				# The custom logger has 'broken' severity which doesn't exist in the inner logger
				# But it should pass through anyway
				chained_logger.broken(MySubject, "It's so janky")
				expect(output).to be(:include?, "It's so janky")
			end
		end
	end
end
