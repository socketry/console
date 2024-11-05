# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require "console/terminal/formatter/failure"
require "console/event/failure"
require "console/terminal"

describe Console::Terminal::Formatter::Failure do
	let(:buffer) {StringIO.new}
	let(:terminal) {Console::Terminal.for(buffer)}
	let(:formatter) {subject.new(terminal)}
	
	let(:event) do
		begin
			raise StandardError, "It failed!"
		rescue => error
			Console::Event::Failure.for(error)
		end
	end
	
	it "can format failure events" do
		formatter.format(event.to_hash, buffer)
		
		expect(buffer.string).to be =~ /StandardError: It failed!/
	end
end
