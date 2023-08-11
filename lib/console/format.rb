# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require_relative 'format/safe'

module Console
	module Format
		def self.default
			Safe.new(format: ::JSON)
		end
		
		def self.default_json
			self.default
		end
	end
end
