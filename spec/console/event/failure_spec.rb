require 'console'
require 'console/capture'

RSpec.describe Console::Event::Failure do
	let(:output) {StringIO.new}
	let(:terminal) {Console::Terminal.for(output)}
	let(:error) {
		RuntimeError.new("Test").tap {|e|
			e.set_backtrace([
				"(irb):2:in `rescue in irb_binding'",
				"(irb):1:in `irb_binding'",
				"/path/to/root/.gem/ruby/2.5.7/gems/irb-1.2.7/lib/irb/workspace.rb:114:in `eval'",
				"/path/to/root/.gem/ruby/2.5.7/gems/irb-1.2.7/lib/irb/workspace.rb:114:in `evaluate'",
				"/path/to/root/.gem/ruby/2.5.7/gems/irb-1.2.7/lib/irb/context.rb:450:in `evaluate'",
				"/path/to/root/.gem/ruby/2.5.7/gems/irb-1.2.7/lib/irb.rb:541:in `block (2 levels) in eval_input'",
				"/path/to/root/.gem/ruby/2.5.7/gems/irb-1.2.7/lib/irb.rb:704:in `signal_status'",
				"/path/to/root/.gem/ruby/2.5.7/gems/irb-1.2.7/lib/irb.rb:538:in `block in eval_input'",
				"/path/to/root/.gem/ruby/2.5.7/gems/irb-1.2.7/lib/irb/ruby-lex.rb:166:in `block (2 levels) in each_top_level_statement'",
				"/path/to/root/.gem/ruby/2.5.7/gems/irb-1.2.7/lib/irb/ruby-lex.rb:151:in `loop'",
				"/path/to/root/.gem/ruby/2.5.7/gems/irb-1.2.7/lib/irb/ruby-lex.rb:151:in `block in each_top_level_statement'",
				"/path/to/root/.gem/ruby/2.5.7/gems/irb-1.2.7/lib/irb/ruby-lex.rb:150:in `catch'",
				"/path/to/root/.gem/ruby/2.5.7/gems/irb-1.2.7/lib/irb/ruby-lex.rb:150:in `each_top_level_statement'",
				"/path/to/root/.gem/ruby/2.5.7/gems/irb-1.2.7/lib/irb.rb:537:in `eval_input'",
				"/path/to/root/.gem/ruby/2.5.7/gems/irb-1.2.7/lib/irb.rb:472:in `block in run'",
				"/path/to/root/.gem/ruby/2.5.7/gems/irb-1.2.7/lib/irb.rb:471:in `catch'",
				"/path/to/root/.gem/ruby/2.5.7/gems/irb-1.2.7/lib/irb.rb:471:in `run'",
				"/path/to/root/.gem/ruby/2.5.7/gems/irb-1.2.7/lib/irb.rb:400:in `start'",
				"/path/to/root/.gem/ruby/2.5.7/gems/irb-1.2.7/exe/irb:11:in `<top (required)>'",
				"/path/to/root/.gem/ruby/2.5.7/bin/irb:23:in `load'",
				"/path/to/root/.gem/ruby/2.5.7/bin/irb:23:in `<main>'"
			])
		}
	}
	
	it "formats exception removing root path" do
		event = Console::Event::Failure.new(error, "/path/to/root")
		event.format(output, terminal, true)
		expect(output.string.lines[3..-1]).to all match(/^\s+\.gem/)
	end
end
