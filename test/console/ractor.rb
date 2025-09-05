# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "console"

return unless defined?(Ractor::Port)

describe Console do
	with Ractor do
		it "can log messages from within a ractor" do
			port = Ractor::Port.new
			
			ractor = Ractor.new(port) do |port|
				require "console"
				require "console/capture"
				
				# Use capture to avoid stderr output during tests
				capture = Console::Capture.new
				Console.logger = Console::Logger.new(capture)
				
				Console.info("Hello from Ractor!")
				Console.warn("Warning from Ractor!")
				Console.error("Error from Ractor!")
				
				port.send({
					result: "Ractor completed successfully",
					messages: capture.records.map {|record| record[:subject]}
				})
			end
			
			output = port.receive
			expect(output[:result]).to be == "Ractor completed successfully"
			expect(output[:messages]).to be == ["Hello from Ractor!", "Warning from Ractor!", "Error from Ractor!"]
		end
		
		it "can handle multiple concurrent ractors" do
			port = Ractor::Port.new
			
			ractors = 3.times.map do |i|
				Ractor.new(port, i) do |port, id|
					require "console"
					require "console/capture"
					
					# Use capture to avoid stderr output during tests
					capture = Console::Capture.new
					Console.logger = Console::Logger.new(capture)
					
					Console.info("Ractor #{id}", "Starting work")
					sleep(0.01) # Brief work simulation
					Console.info("Ractor #{id}", "Finished work")
					
					port.send({
						result: "Ractor #{id} completed",
						messages: capture.records.map{|record| record[:subject]}
					})
				end
			end
			
			outputs = 3.times.map{port.receive}.sort_by{|output| output[:result]}
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
			port = Ractor::Port.new
			
			ractor = Ractor.new(port) do |port|
				require "console"
				require "console/capture"
				
				# Create a capture output for testing
				capture = Console::Capture.new
				logger = Console::Logger.new(capture)
				
				logger.info("Captured message")
				logger.warn("Captured warning")
				
				# Return the captured messages
				port.send(capture.records.map{|record| record[:subject]})
			end

			captured_messages = port.receive
			expect(captured_messages).to be == ["Captured message", "Captured warning"]
		end
	end
end
