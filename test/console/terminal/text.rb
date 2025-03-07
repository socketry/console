# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2024, by Samuel Williams.

require "console/terminal/xterm"

describe Console::Terminal::Text do
	let(:stream) {StringIO.new}
	let(:terminal) {subject.new(stream)}
	
	it "can print text" do
		terminal.print("Hello World")
		
		expect(stream.string).to be == "Hello World"
	end
	
	it "can print a proc" do
		terminal.print(->(stream){stream.print("Hello World")})
		
		expect(stream.string).to be == "Hello World"
	end
	
	it "can puts text" do
		terminal.puts("Hello World")
		
		expect(stream.string).to be == "Hello World\n"
	end
	
	it "can write text" do
		terminal.write("Hello World")
		
		expect(stream.string).to be == "Hello World"
	end
end
