# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

require 'console/logger'
require 'console/capture'
require 'my_custom_output'

describe Console::Output do
	let(:capture) {StringIO.new}
	let(:env) {Hash.new}
	let(:output) {Console::Output.new(capture, env)}
	
	describe '.new' do
		with 'output to a file' do
			let(:capture) {File.open('/tmp/console.log', 'w')}
			
			it 'should use a serialized format' do
				expect(output).to be_a(Console::Serialized::Logger)
			end
		end
		
		with 'output to $stderr' do
			let(:capture) {$stderr}
			
			it 'should use a terminal format' do
				expect($stderr).to receive(:tty?).and_return(true)
				
				expect(output).to be_a Console::Terminal::Logger
			end
		end
		
		with env: {'CONSOLE_OUTPUT' => 'JSON'} do
			it 'can set output to Serialized and format to JSON' do
				expect(output).to be_a Console::Serialized::Logger
				expect(output.format).to be_a(Console::Format::Safe)
			end
		end
		
		with env: {'CONSOLE_OUTPUT' => 'MyCustomOutput'} do
			it 'can set output to Serialized using custom format by ENV' do
				expect(output).to be_a MyCustomOutput
			end
		end
		
		with env: {'CONSOLE_OUTPUT' => 'InvalidOutput'} do
			it 'raises error until the given format class is available' do
				expect{output}.to raise_exception(NameError, message: be =~ /Console::Output::InvalidOutput/)
			end
		end
		
		with env: {'CONSOLE_OUTPUT' => 'XTerm'} do
			it 'can force format to XTerm for non tty output by ENV' do
				expect(Console::Terminal).not.to receive(:for)
				expect(output).to be_a Console::Terminal::Logger
				expect(output.terminal).to be_a Console::Terminal::XTerm
			end
		end
		
		with env: {'CONSOLE_OUTPUT' => 'Text'} do
			it 'can force format to text for tty output by ENV using Text' do
				expect(Console::Terminal).not.to receive(:for)
				expect(output).to be_a Console::Terminal::Logger
				expect(output.terminal).to be_a Console::Terminal::Text
			end
		end
	end
	
	with "invalid UTF-8" do
		it "should replace invalid characters" do
			expect(capture).to receive(:tty?).and_return(false)
			
			output.call("Hello \xFF")
			
			message = JSON.parse(capture.string)
			expect(message['subject']).to be == "Hello \uFFFD"
		end
	end
	
	with "recursive arguments" do
		it "should replace top level recursion" do
			arguments = []
			arguments << arguments
			
			output.call("Hello", arguments)
			
			message = JSON.parse(capture.string)
			expect(message['truncated']).to be == true
			expect(message['message']).to be == ["[...]"]
		end
		
		it "should replace nested recursion" do
			arguments = {}
			arguments[:arguments] = arguments
			
			output.call("Hello", arguments)
			
			message = JSON.parse(capture.string)
			expect(message['truncated']).to be == true
			expect(message['message']).to be == {"arguments"=>"{...}"}
		end
	end
end
