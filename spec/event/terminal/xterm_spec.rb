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

require 'event/terminal/xterm'

RSpec.describe Event::Terminal::XTerm do
	let(:io) {StringIO.new}
	subject{described_class.new(io)}
	
	it "can generate simple style" do
		expect(subject.style(:blue)).to be == "\e[34m"
	end
	
	it "can generate complex style" do
		expect(subject.style(:blue, nil, :underline, :bold)).to be == "\e[34;4;1m"
	end
	
	it "can write text with specified style" do
		subject[:bold] = subject.style(nil, nil, :bold)
		
		subject.write("Hello World", style: :bold)
		
		expect(io.string).to be == "\e[1mHello World\e[0m"
	end
	
	it "can puts text with specified style" do
		subject[:bold] = subject.style(nil, nil, :bold)
		
		subject.puts("Hello World", style: :bold)
		
		expect(io.string.split(/\r?\n/)).to be == ["\e[1mHello World", "\e[0m"]
	end
end
