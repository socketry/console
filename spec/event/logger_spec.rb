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

require 'event'

RSpec.describe Event::Logger do
	let(:output) {StringIO.new}
	subject{described_class.new(output)}
	
	let(:message) {"Hello World"}
	
	context "default log level" do
		it "logs info" do
			subject.info(message)
			
			expect(output.string).to include message
		end
		
		it "doesn't log debug" do
			subject.debug(message)
			
			expect(output.string).to_not include message
		end
		
		it "can log to buffer" do
			subject.info do |buffer|
				buffer << message
			end
			
			expect(output.string).to include message
		end
	end
	
	described_class::LEVELS.each do |name, level|
		it "can log #{name} messages" do
			subject.level = level
			subject.log(name, message)
			
			expect(output.string).to include message
		end
	end
	
	describe '#enable' do
		let(:object) {Object.new}
		
		it "can enable specific subjects" do
			subject.warn!
			
			subject.enable(object)
			expect(subject).to be_enabled(object)
			
			subject.debug(object, message)
			expect(output.string).to include message
		end
	end
end
