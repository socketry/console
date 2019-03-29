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
	
	describe '#dup' do
		let(:nested) {subject.dup(name: "nested")}
		
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
end
