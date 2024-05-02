require 'sus/shared'

module Console
	CapturedOutput = Sus::Shared("captured output") do
		let(:capture) {Console::Capture.new}
		let(:logger) {Console::Logger.new(capture)}
		
		def around
			Fiber.new do
				Console.logger = logger
				super
			end.resume
		end	
	end
end
