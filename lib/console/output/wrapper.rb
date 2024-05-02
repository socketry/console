# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

module Console
	module Output
		class Wrapper
			def initialize(delegate, **options)
				@delegate = delegate
			end
			
			def verbose!(value = true)
				@delegate.verbose!(value)
			end
			
			def call(...)
				@delegate.call(...)
			end
		end
	end
end
