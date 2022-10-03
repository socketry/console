# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2022, by Samuel Williams.

module Console
	module Event
		class Generic
			def self.register(terminal)
			end
			
			def to_h
			end
			
			def to_json(*arguments)
				JSON.generate([self.class, to_h], *arguments)
			end
			
			def format(buffer, terminal)
			end
		end
	end
end
