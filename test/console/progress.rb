# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2022, by Samuel Williams.

require 'console'
require 'console/progress'
require 'console/capture'

describe Console::Progress do
	let(:capture) {Console::Capture.new}
	let(:logger) {Console::Logger.new(capture)}
	let(:progress) {logger.progress("My Measurement", 100)}
	
	with '#mark' do
		it "can mark progress" do
			progress.mark("Hello World!")
			
			last = capture.last
			expect(last).to have_keys(
				severity: be == :info,
				subject: be == "My Measurement",
				arguments: be == ["Hello World!"],
			)
		end
	end
	
	with '#resize' do
		it "can resize the progress bar total" do
			progress.resize(200)
			
			expect(progress.total).to be == 200
		end
	end
	
	with '#to_s' do
		it "can generate a brief summary" do
			expect(progress.to_s).to be == "0/100 completed, waiting for estimate..."
			progress.increment(1)
			expect(progress.to_s).to be =~ /1\/100 completed in 0\.\d+s, \d.\d+s remaining/
			progress.increment(1)
			expect(progress.to_s).to be =~ /2\/100 completed in 0\.\d+s, \d.\d+s remaining/
		end
	end
	
	with '#increment' do
		it 'can create new measurement' do
			expect(progress.ratio).to be == 0.0
			
			expect(progress.current).to be == 0
			expect(progress.total).to be == 100
			expect(progress.subject).to be == "My Measurement"
			
			progress.increment(50)
			expect(progress.average_duration).to be_a(Float)
			expect(progress.duration).to be_a(Float)
			expect(progress.ratio).to be == 0.5
			expect(progress.estimated_remaining_time).to be > 0.0
			
			progress.increment(50)
			expect(progress.estimated_remaining_time).to be == 0.0
			
			last = capture.last
			expect(last).to have_keys(
				severity: be == :info,
				subject: be == "My Measurement",
				message: be_a(Console::Event::Progress),
			)
		end
		
		it 'can generate a progress bar' do
			progress.increment(50)
			
			last = capture.last
			message = last[:message]
			
			terminal = Console::Terminal::Text.new($stderr)
			output = StringIO.new
			message.format(output, terminal, true)
			
			expect(output.string).to be == "███████████████████████████████████                                     50.00%\n"
		end
	end
end
