# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2022, by Samuel Williams.

require 'console/terminal/xterm'

describe Console::Terminal::Text do
	let(:io) {StringIO.new}
	let(:terminal) {subject.new(io)}
	
	it "can print text" do
		terminal.print("Hello World")
		
		expect(io.string).to be == "Hello World"
	end
	
	it "can print a proc" do
		terminal.print(->(io){io.print("Hello World")})
		
		expect(io.string).to be == "Hello World"
	end
	
	it "can puts text" do
		terminal.puts("Hello World")
		
		expect(io.string).to be == "Hello World\n"
	end
	
	it "can write text" do
		terminal.write("Hello World")
		
		expect(io.string).to be == "Hello World"
	end
end
