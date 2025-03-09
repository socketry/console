# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2025, by Samuel Williams.

require "console/progress"
require "sus/fixtures/console"

describe Console::Progress do
	include_context Sus::Fixtures::Console::CapturedLogger
	
	let(:progress) {console_logger.progress("My Measurement", 100)}
	
	with ".now" do
		it "can measure time" do
			expect(Console::Progress.now).to be_a(Float)
		end
	end
	
	with "#mark" do
		it "can mark progress" do
			progress.mark("Hello World!")
			
			expect(console_capture.last).to have_keys(
				severity: be == :info,
				subject: be == "My Measurement",
				arguments: be == ["Hello World!"],
			)
		end
	end
	
	with "#resize" do
		it "can resize the progress bar total" do
			progress.resize(200)
			
			expect(progress.total).to be == 200
		end
	end
	
	with "#to_s" do
		it "can generate a brief summary" do
			expect(progress.to_s).to be == "0/100 completed, waiting for estimate..."
			progress.increment(1)
			expect(progress.to_s).to be =~ /1\/100 completed in 0\.\d+s, \d.\d+s remaining/
			progress.increment(1)
			expect(progress.to_s).to be =~ /2\/100 completed in 0\.\d+s, \d.\d+s remaining/
		end
	end
	
	with "#increment" do
		it "can create new measurement" do
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
			
			expect(console_capture.last).to have_keys(
				severity: be == :info,
				subject: be == "My Measurement",
				arguments: have_attributes(first: be =~ /100\/100 completed in .*?, 0.0s remaining\./),
				event: have_keys(
					type: be == :progress,
					current: be == 100,
					total: be == 100,
				),
			)
		end
	end
end
