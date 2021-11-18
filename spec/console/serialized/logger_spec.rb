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

require 'console/serialized/logger'

RSpec.describe Console::Serialized::Logger do
	let(:io) {StringIO.new}
	subject{described_class.new(io)}
	
	let(:message) {"Hello World"}
	
	let(:record) {JSON.parse(io.string, symbolize_names: true)}
	
	it "can log to buffer" do
		subject.call do |buffer|
			buffer << message
		end
		
		expect(record).to include :message
		expect(record[:message]).to be == message
	end
	
	it "can log options" do
		subject.call(name: "request-id")
		
		record = JSON.parse(io.string, symbolize_names: true)
		
		expect(record).to include(:name)
		expect(record[:name]).to be == "request-id"
	end
	
	context 'with structured event' do
		let(:event) {Console::Event::Spawn.for("ls -lah")}
		
		it "can log structured events" do
			subject.call(event)
			
			record = JSON.parse(io.string, symbolize_names: true)
			
			expect(record).to include(:subject)
			expect(record[:subject]).to be == ["Console::Event::Spawn", {:arguments => ["ls -lah"]}]
		end
	end
end
