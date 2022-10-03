# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2022, by Samuel Williams.

require 'console'
require 'console/progress'

describe Console::Progress do
	with '#increment' do
		it 'can create new measurement' do
			progress = Console.logger.progress("My Measurement", 100)
			
			expect(progress.current).to be == 0
			expect(progress.total).to be == 100
			expect(progress.subject).to be == "My Measurement"
			
			expect(Console.logger).to receive(:info)
			
			progress.increment(50)
		end
	end
end
