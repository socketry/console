# frozen_string_literal: true

# Copyright, 2018, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

require 'console/logger'
require 'console/capture'

class MyCustomOutput
	def initialize(output, **options)
	end
end

RSpec.describe Console::Output do
	describe '.new' do
		context 'when output to $stderr' do
			it 'should set the default to Terminal::Logger' do
				expect($stderr).to receive(:tty?).and_return(true)
				expect(Console::Output.new($stderr)).to be_a Console::Terminal::Logger
			end
		end
		
		it 'can set output to Serialized and format to JSON by ENV' do
			output = Console::Output.new(StringIO.new, {'CONSOLE_OUTPUT' => 'JSON'})
			
			expect(output).to be_a Console::Serialized::Logger
			expect(output.format).to be == JSON
		end
		
		it 'can set output to Serialized using custom format by ENV' do
			output = Console::Output.new(StringIO.new, {'CONSOLE_OUTPUT' => 'MyCustomOutput'})
			
			expect(output).to be_a MyCustomOutput
		end
		
		it 'raises error until the given format class is available' do
			expect {
				Console::Output.new(nil, {'CONSOLE_OUTPUT' => 'InvalidOutput'})
			}.to raise_error(NameError, /Console::Output::InvalidOutput/)
		end
		
		it 'can force format to XTerm for non tty output by ENV' do
			io = StringIO.new
			expect(Console::Terminal).not_to receive(:for).with(io)
			output = Console::Output.new(io, {'CONSOLE_OUTPUT' => 'XTerm'})
			expect(output).to be_a Console::Terminal::Logger
			expect(output.terminal).to be_a Console::Terminal::XTerm
		end
		
		it 'can force format to text for tty output by ENV using Text' do
			io = StringIO.new
			expect(Console::Terminal).not_to receive(:for).with(io)
			output = Console::Output.new(io, {'CONSOLE_OUTPUT' => 'Text'})
			expect(output).to be_a Console::Terminal::Logger
			expect(output.terminal).to be_a Console::Terminal::Text
		end
	end
end
