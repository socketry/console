require 'sus/fixtures/console'

describe "Kernel#warn" do
	include_context Sus::Fixtures::Console::CapturedLogger
	
	it "redirects to Console.warn" do
		warn "It did not work as expected!"
		
		expect(console_capture.last).to have_keys(
			severity: be == :warn,
			subject: be == "It did not work as expected!"
		)
	end
	
	it "supports uplevel" do
		warn "It did not work as expected!", uplevel: 1
		
		expect(console_capture.last).to have_keys(
			severity: be == :warn,
			subject: be == "It did not work as expected!",
			backtrace: be_a(Array)
		)
	end
end
