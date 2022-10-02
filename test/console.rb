# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2021, by Samuel Williams.

require 'console'
require 'my_module'

describe Console do
	it "has a version number" do
		expect(Console::VERSION).not.to be nil
	end
	
	with MyModule do
		let(:io) {StringIO.new}
		let(:logger) {Console::Logger.new(Console::Terminal::Logger.new(io))}
		
		it "should log some messages" do
			MyModule.logger = logger
			MyModule.test_logger
			
			expect(io.string).not.to be(:include?, "GOTO LINE 1")
			expect(io.string).to be(:include?, "There be the dragons!")
		end
		
		it "should show debug messages" do
			MyModule.logger = logger
			MyModule.logger.debug!
			
			MyModule.test_logger
			
			expect(io.string).to be(:include?, "GOTO LINE 1")
		end
		
		it "should log nested exceptions" do
			MyModule.logger = logger
			MyModule.logger.verbose!
			
			MyModule.log_error
			
			expect(io.string).to be(:include?, "Caused by ArgumentError: It broken!")
			expect(MyModule.logger.debug?).to be == false
			expect(MyModule.logger.info?).to be == true
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

