# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2021, by Samuel Williams.

require 'console/terminal/xterm'

RSpec.describe Console::Terminal::XTerm do
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
	
	describe '#print' do
		it "can print using the specified style" do
			subject[:bold] = subject.style(nil, nil, :bold)
			
			subject.print(:bold, "Hello World")
			
			expect(io.string).to be == "\e[1mHello World"
		end
	end
	
	describe '#print_line' do
		it "can print a line using the specified style" do
			subject[:bold] = subject.style(nil, nil, :bold)
			
			subject.print_line(:bold, "Hello World")
			
			expect(io.string.split(/\r?\n/)).to be == ["\e[1mHello World\e[0m"]
		end
	end
end
