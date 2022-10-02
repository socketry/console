# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2021, by Samuel Williams.

require 'console'
require 'console/progress'

RSpec.describe Console::Progress do
	describe '#increment' do
		it 'can create new measurement' do
			progress = Console.logger.progress("My Measurement", 100)
			
			expect(progress.current).to be 0
			expect(progress.total).to be 100
			expect(progress.subject).to be == "My Measurement"
			
			expect(Console.logger).to receive(:info).and_call_original
			
			progress.increment(50)
		end
	end
end
