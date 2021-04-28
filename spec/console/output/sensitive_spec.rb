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

require 'console/output/sensitive'

RSpec.describe Console::Output::Sensitive do
	let(:output) {Console::Capture.new}
	subject{described_class.new(output)}
	
	it 'logs non-sensitive text' do
		subject.call("Hello World")
		
		expect(output).to include("Hello World")
	end
	
	it 'redacts sensitive text' do
		subject.call("first_name: Samuel Williams")
		
		expect(output).to_not include("Samuel Williams")
	end
	
	context 'with sensitive: false' do
		it 'bypasses redaction' do
			subject.call("first_name: Samuel Williams", sensitive: false)
			
			expect(output).to include("Samuel Williams")
		end
	end
	
	context 'with sensitive: Hash' do
		it 'filters specific tokens' do
			subject.call("first_name: Samuel Williams", sensitive: {"Samuel Williams" => "[First Name]"})
			
			expect(output).to include("[First Name]")
			expect(output).to_not include("Samuel Williams")
		end
	end
end
