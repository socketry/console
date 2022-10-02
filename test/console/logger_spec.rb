# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2021, by Samuel Williams.
# Copyright, 2019, by Bryan Powell.
# Copyright, 2020, by Michael Adams.
# Copyright, 2021, by Robert Schulze.

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
end
