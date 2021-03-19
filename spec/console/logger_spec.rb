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

RSpec.describe Console::Logger do
	let(:output) {Console::Capture.new}
	subject{described_class.new(output)}
	
	let(:message) {"Hello World"}
	
	describe '#with' do
		let(:nested) {subject.with(name: "nested", level: :debug)}
		
		it "should change level" do
			expect(nested.level).to be == 0
		end
		
		it "should change name" do
			expect(nested.options[:name]).to be == "nested"
		end
		
		it "logs message with name" do
			nested.error(message)
			
			expect(output.last).to include(
				name: "nested",
				subject: message,
			)
		end
	end
	
	context "with level" do
		let(:level) {0}
		subject{described_class.new(output, level: level)}
		
		it "should have specified log level" do
			expect(subject.level).to be == level
		end
	end
	
	context "default log level" do
		it "logs info" do
			expect(output).to receive(:call).with(message, severity: :info)
			
			subject.info(message)
		end
		
		it "doesn't log debug" do
			expect(output).to_not receive(:call)
			subject.debug(message)
		end
	end
	
	described_class::LEVELS.each do |name, level|
		it "can log #{name} messages" do
			expect(output).to receive(:call).with(message, severity: name)
			
			subject.level = level
			subject.send(name, message)
		end
	end
	
	describe '#enable' do
		let(:object) {Object.new}
		
		it "can enable specific subjects" do
			subject.warn!
			
			subject.enable(object)
			expect(subject).to be_enabled(object)
			
			expect(output).to receive(:call).with(object, message, severity: :debug)
			subject.debug(object, message)
		end
	end
	
	describe "#off!" do
		before do
			subject.off!
		end
		
		described_class::LEVELS.each do |name, level|
			it "doesn't log #{name} messages" do
				expect(output).to_not receive(:call)
				subject.send(name, message)
				expect(subject.send("#{name}?")).to be == false
			end
		end
	end
	
	describe "#all!" do
		before do
			subject.all!
		end
		
		described_class::LEVELS.each do |name, level|
			it "can log #{name} messages" do
				expect(output).to receive(:call).with(message, severity: name)
				subject.send(name, message)
				expect(subject.send("#{name}?")).to be == true
			end
		end
	end
	
	describe '.default_log_level' do
		let!(:debug) {$DEBUG}
		after {$DEBUG = debug}
		
		let!(:verbose) {$VERBOSE}
		after {$VERBOSE = verbose}
		
		it 'should set default log level' do
			$DEBUG = false
			$VERBOSE = 0
			
			expect(Console::Logger.default_log_level).to be == Console::Logger::INFO
		end
		
		it 'should set default log level based on $DEBUG' do
			$DEBUG = true
			
			expect(Console::Logger.default_log_level).to be == Console::Logger::DEBUG
		end
		
		it 'should set default log level based on $VERBOSE' do
			$DEBUG = false
			$VERBOSE = true
			
			expect(Console::Logger.default_log_level).to be == Console::Logger::INFO
		end
		
		it 'can get log level from ENV' do
			expect(Console::Logger.default_log_level({'CONSOLE_LEVEL' => 'debug'})).to be == Console::Logger::DEBUG
		end
	end

	describe '.default_output' do
		it 'should set the default output to $stderr' do
			expect(Console::Logger.default_output).to be == $stderr
		end

		it 'can set output to $stdout by ENV via "STDERR"' do
			expect(Console::Logger.default_output({'CONSOLE_OUTPUT' => 'STDERR'})).to be == $stderr
		end

		it 'can set output to $stdout by ENV via "STDOUT"' do
			expect(Console::Logger.default_output({'CONSOLE_OUTPUT' => 'STDOUT'})).to be == $stdout
		end

		it 'can set output to $stdout by ENV via "-"' do
			expect(Console::Logger.default_output({'CONSOLE_OUTPUT' => '-'})).to be == $stdout
		end
	end

	describe '.default_terminal' do
		it 'should set the default to Terminal::Logger' do
			expect(Console::Logger.default_terminal).to be_a Console::Terminal::Logger
		end

		it 'should set the loggers io to the default_output' do
			expect(Console::Logger.default_terminal.io).to be == Console::Logger.default_output
		end

		it 'can set terminal to Serialized and format to JSON by ENV' do
			terminal = Console::Logger.default_terminal(nil, {'CONSOLE_FORMAT' => 'JSON'})
			expect(terminal).to be_a Console::Serialized::Logger
			expect(terminal.format).to be == JSON
		end

		it 'can set terminal to Serialized using custom format by ENV' do
			class MySerializer
			end
			terminal = Console::Logger.default_terminal(nil, {'CONSOLE_FORMAT' => 'MySerializer'})
			expect(terminal).to be_a Console::Serialized::Logger
			expect(terminal.format).to be == MySerializer
		end

		it 'raises error until the given format class is available' do
			expect {
				Console::Logger.default_terminal(nil, {'CONSOLE_FORMAT' => 'NotThereYet'})
			}.to raise_error(RuntimeError, 'No format found for NotThereYet')
		end

		it 'can force format to XTERM for non tty output by ENV' do
			io = StringIO.new
			terminal = Console::Logger.default_terminal(io, {'CONSOLE_FORMAT' => 'XTERM'})
			expect(terminal).to be_a Console::Terminal::Logger
			expect(terminal.terminal).to be_a Console::Terminal::XTerm
		end

		it 'can force format to TEXT for tty output by ENV using TERM' do
			File.open("/dev/tty") { |io|
				terminal = Console::Logger.default_terminal(io, {'CONSOLE_FORMAT' => 'TERM'})
				expect(terminal).to be_a Console::Terminal::Logger
				expect(terminal.terminal).to be_a Console::Terminal::Text
			}
		end

		it 'can force format to TEXT for tty output by ENV using TEXT' do
			File.open("/dev/tty") { |io|
				terminal = Console::Logger.default_terminal(io, {'CONSOLE_FORMAT' => 'TEXT'})
				expect(terminal).to be_a Console::Terminal::Logger
				expect(terminal.terminal).to be_a Console::Terminal::Text
			}
		end
	end
end
