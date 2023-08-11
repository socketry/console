# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

module Console
	module Output
		# @deprecated With no replacement.
		class Encoder
			def initialize(output, encoding = ::Encoding::UTF_8)
				@output = output
				@encoding = encoding
			end
			
			attr :output
			
			attr :encoding
			
			def call(subject = nil, *arguments, **options, &block)
				subject = encode(subject)
				arguments = encode(arguments)
				options = encode(options)
				
				@output.call(subject, *arguments, **options, &block)
			end
			
			def encode(value)
				case value
				when String
					value.encode(@encoding, invalid: :replace, undef: :replace)
				when Array
					value.map{|item| encode(item)}
				when Hash
					value.transform_values{|item| encode(item)}
				else
					value
				end
			end
		end
	end
end
