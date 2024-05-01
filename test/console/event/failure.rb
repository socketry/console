# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021, by Robert Schulze.
# Copyright, 2021-2022, by Samuel Williams.

require 'console'
require 'console/capture'

class TestError < StandardError
	def detailed_message(...)
		"#{super}\nwith details"
	end
end

describe Console::Event::Failure do
	let(:output) {StringIO.new}
	let(:terminal) {Console::Terminal.for(output)}
	
	with 'runtime error' do
		let(:error) do
			RuntimeError.new("Test").tap do |error|
				error.set_backtrace([
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
			end
		end
	end
	
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
	end
end
