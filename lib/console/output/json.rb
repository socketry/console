# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

require_relative '../serialized/logger'

module Console
	module Output
		module JSON
			# This is a safe JSON serializer that will not raise exceptions.
			class Safe
				def initialize(limit: 8, encoding: ::Encoding::UTF_8)
					@limit = limit
					@encoding = encoding
				end
				
				def dump(object)
					::JSON.dump(object, @limit)
				rescue => error
					::JSON.dump(safe_dump(object, error))
				end
				
				private
				
				def default_objects
					Hash.new.compare_by_identity
				end
				
				def safe_dump(object, error)
					object = safe_dump_recurse(object)
					
					object[:truncated] = true
					object[:error] = {
						class: safe_dump_recurse(error.class.name),
						message: safe_dump_recurse(error.message),
					}
					
					return object
				end
				
				def replacement_for(object)
					case object
					when Array
						"[...]"
					when Hash
						"{...}"
					else
						"..."
					end
				end
				
				# This will recursively generate a safe version of the object.
				# Nested hashes and arrays will be transformed recursively.
				# Strings will be encoded with the given encoding.
				# Primitive values will be returned as-is.
				# Other values will be converted using `as_json` if available, otherwise `to_s`.
				def safe_dump_recurse(object, limit = @limit, objects = default_objects)
					if limit <= 0 || objects[object]
						return replacement_for(object)
					end
					
					case object
					when Hash
						objects[object] = true
						
						object.to_h do |key, value|
							[
								String(key).encode(@encoding, invalid: :replace, undef: :replace),
								safe_dump_recurse(value, limit - 1, objects)
							]
						end
					when Array
						objects[object] = true
						
						object.map do |value|
							safe_dump_recurse(value, limit - 1, objects)
						end
					when String
						object.encode(@encoding, invalid: :replace, undef: :replace)
					when Numeric, TrueClass, FalseClass, NilClass
						object
					else
						objects[object] = true
						
						# We could do something like this but the chance `as_json` will blow up.
						# We'd need to be extremely careful about it.
						# if object.respond_to?(:as_json)
						# 	safe_dump_recurse(object.as_json, limit - 1, objects)
						# else
						
						safe_dump_recurse(object.to_s, limit - 1, objects)
					end
				end
			end
			
			def self.new(output, **options)
				Serialized::Logger.new(output, format: Safe.new, **options)
			end
		end
	end
end
