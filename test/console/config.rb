# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "console/config"

describe Console::Config do
	let(:config) {subject.new}
	
	with "#make_output" do
		it "can create an output" do
			output = config.make_output
			
			expect(output).to be(:respond_to?, :call)
		end
	end
	
	with "#make_logger" do
		it "can create a logger" do
			logger = config.make_logger
			
			expect(logger).to be_a Console::Logger
		end
	end
	
	with ".load" do
		let(:path) {File.expand_path(".config/console_debug.rb", __dir__)}
		
		it "can load configuration" do
			config = subject.load(path)
			
			expect(config.log_level).to be == :debug
		end
	end
end
