# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2023, by Samuel Williams.
# Copyright, 2019, by Bryan Powell.
# Copyright, 2020, by Michael Adams.

require 'console'
require 'my_module'

describe Console do
	it "has a version number" do
		expect(Console::VERSION).to be =~ /\d+\.\d+\.\d+/
	end
	
	it "has interface methods for all log levels" do
		Console::Logger::LEVELS.each do |name, level|
			expect(Console).to be(:respond_to?, name)
		end
	end
	
	with MyModule do
		let(:io) {StringIO.new}
		let(:logger) {Console::Logger.new(Console::Terminal::Logger.new(io))}
		
		it "should log some messages" do
			Fiber.new do
				Console.logger = logger
				MyModule.test_logger
			end.resume
			
			expect(io.string).not.to be(:include?, "GOTO LINE 1")
			expect(io.string).to be(:include?, "There be the dragons!")
		end
		
		it "should show debug messages" do
			Fiber.new do
				Console.logger = logger
				MyModule.logger.debug!
				MyModule.test_logger
			end.resume
			
			expect(io.string).to be(:include?, "GOTO LINE 1")
		end
		
		it "should log nested exceptions" do
			expect(logger.debug?).to be == false
			expect(logger.info?).to be == true
			
			Fiber.new do
				Console.logger = logger
				logger.verbose!
				MyModule.log_error
			end.resume
			
			expect(io.string).to be(:include?, "Caused by ArgumentError: It broken!")
		end
	end
	
	with '#logger' do
		def before
			@original_logger = subject.logger
			
			super
		end
		
		def after
			subject.logger = @original_logger
			
			super
		end
		
		it 'sets and returns a logger' do
			logger = Console::Logger.new(subject.logger.output)
			subject.logger = logger
			expect(subject.logger).to be(:eql?, logger)
		end
	end
end

