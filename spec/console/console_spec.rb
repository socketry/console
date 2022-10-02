# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2021, by Samuel Williams.
# Copyright, 2019, by Bryan Powell.
# Copyright, 2020, by Michael Adams.

require 'console'

require_relative 'my_module'

RSpec.describe Console do
	context MyModule do
		let(:io) {StringIO.new}
		let(:logger) {Console::Logger.new(Console::Terminal::Logger.new(io))}
		
		it "should log some messages" do
			MyModule.logger = logger
			MyModule.test_logger
			
			expect(io.string).to_not include("GOTO LINE 1")
			expect(io.string).to include("There be the dragons!")
		end
		
		it "should show debug messages" do
			MyModule.logger = logger
			MyModule.logger.debug!
			
			MyModule.test_logger
			
			expect(io.string).to include("GOTO LINE 1")
		end
		
		it "should log nested exceptions" do
			MyModule.logger = logger
			MyModule.logger.verbose!
			
			MyModule.log_error
			
			expect(io.string).to include("Caused by ArgumentError: It broken!")
			expect(MyModule.logger.debug?).to be == false
			expect(MyModule.logger.info?).to be == true
		end
	end
	
	describe '#logger' do
		let!(:original_logger) {described_class.logger}
		
		after do
			described_class.logger = original_logger
		end
		
		it 'sets and returns a logger' do
			logger = double(:logger)
			described_class.logger = logger
			expect(described_class.logger).to be(logger)
		end
	end
end
