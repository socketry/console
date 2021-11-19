# frozen_string_literal: true

# Copyright, 2019, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

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
