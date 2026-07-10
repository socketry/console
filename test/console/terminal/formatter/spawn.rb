# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "console/terminal/formatter/spawn"
require "console/terminal"

describe Console::Terminal::Formatter::Spawn do
	let(:buffer) {StringIO.new}
	let(:terminal) {Console::Terminal.for(buffer)}
	let(:formatter) {subject.new(terminal)}
	
	it "can format spawn events" do
		formatter.format({arguments: ["ls", "-lah"]}, buffer)
		
		expect(buffer.string).to be(:include?, "ls -lah")
	end
	
	it "can format working directories" do
		formatter.format({arguments: ["ls"], options: {chdir: "/tmp"}}, buffer)
		
		expect(buffer.string).to be(:include?, "in /tmp")
	end
	
	it "can format environment variables in verbose mode" do
		formatter.format({environment: {"TERM" => "dumb"}, arguments: ["env"]}, buffer, verbose: true)
		
		expect(buffer.string).to be(:include?, "export TERM=dumb")
	end
end
