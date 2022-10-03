# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

require_relative '../serialized/logger'

module Console
	module Output
		module JSON
			def self.new(output, **options)
				Serialized::Logger.new(output, format: ::JSON, **options)
			end
		end
	end
end
