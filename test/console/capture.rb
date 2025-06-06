# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2025, by Samuel Williams.

require "console/capture"
require "console/logger"

describe Console::Capture do
	let(:capture) {subject.new}
	let(:logger) {Console::Logger.new(capture)}
	
	with "#each" do
		it "can iterate over log buffer" do
			logger.info("Hello World!")
			
			capture.each do |entry|
				expect(entry).to have_keys(
					severity: be == :info,
					subject: be == "Hello World!"
				)
			end
		end
	end
	
	with "#first" do
		it "can access first log entry" do
			logger.info("Goodbye World!")
			logger.info("Hello World!")
			
			first = capture.first
			expect(first).to have_keys(
				severity: be == :info,
				subject: be == "Goodbye World!"
			)
		end
	end
	
	with "#last" do
		it "can access last log entry" do
			logger.info("Goodbye World!")
			logger.info("Hello World!")
			
			last = capture.last
			expect(last).to have_keys(
				severity: be == :info,
				subject: be == "Hello World!"
			)
		end
	end
	
	with "#clear" do
		it "can clear log buffer" do
			logger.info("Hello World!")
			capture.clear
			
			expect(capture).to be(:empty?)
		end
	end
	
	with "#buffer" do
		it "can access log buffer" do
			logger.info("Hello World!")
			
			last = capture.last
			expect(last).to have_keys(
				severity: be == :info,
				subject: be == "Hello World!"
			)
		end
	end
	
	with "block" do
		it "can capture log output" do
			logger.info(self) {"Hello World!"}
			
			last = capture.last
			expect(last).to have_keys(
				severity: be == :info,
				message: be == "Hello World!"
			)
		end
		
		it "can capture log output with buffer" do
			logger.info(self) do |buffer|
				buffer << "Hello World!"
			end
			
			last = capture.last
			expect(last).to have_keys(
				severity: be == :info,
				message: be == "Hello World!"
			)
		end
	end
end
