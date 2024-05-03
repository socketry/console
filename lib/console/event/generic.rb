# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2024, by Samuel Williams.

module Console
	module Event
		class Generic
			def as_json(...)
				to_hash
			end
			
			def to_json(...)
				JSON.generate(as_json, ...)
			end
			
			def to_s
				to_json
			end
			
			def emit(*arguments, **options)
				Console.call(*arguments, event: self, **options)
			end
		end
	end
end
