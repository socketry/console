# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2022, by Samuel Williams.

require_relative 'generic'

module Console
	module Event
		class Progress < Generic
			BLOCK = [
				" ",
				"▏",
				"▎",
				"▍",
				"▌",
				"▋",
				"▊",
				"▉",
				"█",
			]
			
			def initialize(current, total)
				@current = current
				@total = total
			end
			
			attr :current
			attr :total
			
			def value
				@current.to_f / @total.to_f
			end
			
			def bar(value = self.value, width = 70)
				blocks = width * value
				full_blocks = blocks.floor
				partial_block = ((blocks - full_blocks) * BLOCK.size).floor
				
				if partial_block.zero?
					BLOCK.last * full_blocks
				else
					"#{BLOCK.last * full_blocks}#{BLOCK[partial_block]}"
				end.ljust(width)
			end
			
			def self.register(terminal)
				terminal[:progress_bar] ||= terminal.style(:blue, :white)
			end
			
			def to_h
				{current: @current, total: @total}
			end
			
			def format(output, terminal, verbose)
				output.puts "#{terminal[:progress_bar]}#{self.bar}#{terminal.reset} #{sprintf('%6.2f', self.value * 100)}%"
			end
		end
	end
end
