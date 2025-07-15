# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "console"

return unless defined?(Ractor)

# Ractors are more or less broken in older Ruby versions, so we require Ruby 3.4 or later for Ractor compatibility.
return unless RUBY_VERSION >= "3.4"

describe Console do
	with Ractor do
		it "can log messages from within a ractor" do
			ractor = Ractor.new do
				require "console"
				require "console/capture"
				
				# Use capture to avoid stderr output during tests
				capture = Console::Capture.new
				Console.logger = Console::Logger.new(capture)
				
				Console.info("Hello from Ractor!")
				Console.warn("Warning from Ractor!")
				Console.error("Error from Ractor!")
				
				{
					result: "Ractor completed successfully",
					messages: capture.records.map {|record| record[:subject]}
				}
			end
			
			output = ractor.take
			expect(output[:result]).to be == "Ractor completed successfully"
			expect(output[:messages]).to be == ["Hello from Ractor!", "Warning from Ractor!", "Error from Ractor!"]
		end
		
		it "can handle multiple concurrent ractors" do
			ractors = 3.times.map do |i|
				Ractor.new(i) do |id|
					require "console"
					require "console/capture"
					
					# Use capture to avoid stderr output during tests
					capture = Console::Capture.new
					Console.logger = Console::Logger.new(capture)
					
					Console.info("Ractor #{id}", "Starting work")
					sleep(0.01) # Brief work simulation
					Console.info("Ractor #{id}", "Finished work")
					
					{
						result: "Ractor #{id} completed",
						messages: capture.records.map{|record| record[:subject]}
					}
				end
			end
			
			outputs = ractors.map(&:take)
			results = outputs.map{|output| output[:result]}
			
			expect(results).to be == [
				"Ractor 0 completed",
				"Ractor 1 completed", 
				"Ractor 2 completed"
			]
			
			# Verify each ractor logged the expected messages
			outputs.each_with_index do |output, i|
				expect(output[:messages]).to be == ["Ractor #{i}", "Ractor #{i}"]
			end
		end
		
		it "can use custom loggers in ractors" do
			ractor = Ractor.new do
				require "console"
				require "console/capture"
				
				# Create a capture output for testing
				capture = Console::Capture.new
				logger = Console::Logger.new(capture)
				
				logger.info("Captured message")
				logger.warn("Captured warning")
				
				# Return the captured messages
				capture.records.map{|record| record[:subject]}
			end
			
			captured_messages = ractor.take
			expect(captured_messages).to be == ["Captured message", "Captured warning"]
		end
	end
end
