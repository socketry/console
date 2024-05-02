# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021, by Robert Schulze.
# Copyright, 2021-2022, by Samuel Williams.

require 'console'
require 'console/capture'
require 'console/captured_output'

class TestError < StandardError
	def detailed_message(...)
		"#{super}\nwith details"
	end
end

describe Console::Event::Failure do
	include_context Console::CapturedOutput
	
	with 'test error' do
		let(:error) do
			begin
				raise TestError, "Test error!"
			rescue TestError => error
				error
			end
		end
		
		it "includes detailed message" do
			skip_unless_method_defined(:detailed_message, Exception)
			
			expect(error.detailed_message).to be =~ /with details/
			
			event = Console::Event::Failure.new(error)
			
			expect(event.to_hash).to have_keys(
				message: be =~ /Test error!\nwith details/
			)
		end
		
		it "logs error message" do
			Console::Event::Failure.for(error).emit(self)
			
			last = capture.last
			expect(last).to have_keys(
				severity: be == :error,
				subject: be == self,
				event: have_keys(
					type: be == :failure,
					root: be_a(String),
					class: be =~ /TestError/,
					message: be =~ /Test error!/,
					backtrace: be_a(Array),
				)
			)
		end
	end
end
