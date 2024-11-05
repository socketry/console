# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2024, by Samuel Williams.

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
			expect{
				logger.enable("Hello World")
			}.to raise_exception(ArgumentError)
		end
	end
	
	with "#clear" do
		it "can't clear non-class subjects" do
			expect{
				logger.clear("Hello World")
			}.to raise_exception(ArgumentError)
		end
	end
	
	with "#call" do
		it "ignores messages below the level" do
			logger.level = Console::Logger::INFO
			
			logger.call(MySubject, "Hello World", severity: :debug)
			
			expect(output).to be(:empty?)
		end
		
		it "logs messages at the level" do
			logger.level = Console::Logger::INFO
			
			logger.call(MySubject, "Hello World", severity: :info)
			
			expect(output).to be(:include?, "Hello World")
		end
		
		it "logs messages above the level" do
			logger.level = Console::Logger::INFO
			
			logger.call(MySubject, "Hello World", severity: :warn)
			
			expect(output).to be(:include?, "Hello World")
		end
	end
end
