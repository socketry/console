# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2021, by Samuel Williams.

require 'console'

RSpec.describe Console::Measure do
	describe '#increment' do
		it 'can create new measurement' do
			expect(Console.logger).to receive(:info) do |subject, &block|
				expect(block.call).to be_kind_of(Console::Event::Enter)
				
				expect(Console.logger).to receive(:info) do |subject, &block|
					expect(block.call).to be_kind_of(Console::Event::Exit)
				end
			end
			
			result = Console.logger.measure("My Measurement") do |measure|
				:result
			end
			
			expect(result).to be == :result
		end
	end
end
