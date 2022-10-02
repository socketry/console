# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2021, by Samuel Williams.

require 'console'

describe Console::Measure do
	with '#increment' do
		it 'can create new measurement' do
			events = []
			
			mock(Console.logger) do |mock|
				mock.replace(:info) do |subject, &block|
					events << block.call
				end
			end
			
			result = Console.logger.measure("My Measurement") do |measure|
				:result
			end
			
			expect(result).to be == :result
			expect(events[0]).to be_a(Console::Event::Enter)
			expect(events[1]).to be_a(Console::Event::Exit)
		end
	end
end
