# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

require_relative '../serialized/logger'
require_relative 'encoder'

module Console
	module Output
		module JSON
			def self.new(output, **options)
				# The output encoder can prevent encoding issues (e.g. invalid UTF-8):
				Output::Encoder.new(
					Serialized::Logger.new(output, format: ::JSON, **options)
				)
			end
		end
	end
end
