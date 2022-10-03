# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2022, by Samuel Williams.

require 'stringio'

module Console
	class Buffer < StringIO
		def initialize(prefix = nil)
			@prefix = prefix
			
			super()
		end
		
		def puts(*args, prefix: @prefix)
			args.each do |arg|
				self.write(prefix) if prefix
				super(arg)
			end
		end
		
		alias << puts
	end
end
