# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2024, by Samuel Williams.

require_relative 'format/safe'

module Console
	module Format
		def self.default
			Safe.new(format: ::JSON)
		end
	end
end
