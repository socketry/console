require 'console/terminal/formatter/progress'
require 'console/progress'
require 'console/output/null'
require 'console/terminal'

describe Console::Terminal::Formatter::Progress do
	let(:buffer) {StringIO.new}
	let(:terminal) {Console::Terminal.for(buffer)}
	let(:formatter) {subject.new(terminal)}
	let(:output) {Console::Output::Null.new}
	
	let(:progress) do
		Console::Progress.new(output, self, 10)
	end
	
	it "can format failure events" do
		formatter.format(progress.to_hash, buffer)
		
		expect(buffer.string).to be =~ /0.00%/
	end
end