# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2023, by Samuel Williams.

require_relative '../serialized/logger'

module Console
	module Output
		module JSON
			def self.new(output, **options)
				Serialized::Logger.new(output, format: Format.default_json, **options)
			end
		end
	end
end
