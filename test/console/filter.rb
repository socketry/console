# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2025, by Samuel Williams.

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
end
