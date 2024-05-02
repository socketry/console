# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

module Console
	module Terminal
		module Formatter
			class Progress
				KEY = :progress
				
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
				
				def initialize(terminal)
					@terminal = terminal
					@terminal[:progress_bar] ||= terminal.style(:blue, :white)
				end
				
				def format(event, output, verbose: false, width: 80)
					current = event[:current].to_f
					total = event[:total].to_f
					value = current / total
					
					# Clamp value to 1.0 to avoid rendering issues:
					if value > 1.0
						value = 1.0
					end
					
					output.puts "#{@terminal[:progress_bar]}#{self.bar(value, width-10)}#{@terminal.reset} #{sprintf('%6.2f', value * 100)}%"
				end
				
				private
				
				def bar(value, width)
					blocks = width * value
					full_blocks = blocks.floor
					partial_block = ((blocks - full_blocks) * BLOCK.size).floor
					
					if partial_block.zero?
						BLOCK.last * full_blocks
					else
						"#{BLOCK.last * full_blocks}#{BLOCK[partial_block]}"
					end.ljust(width)
				end
			end
		end
	end
end
