# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require 'json'

module Console
	module Format
		# This class is used to safely dump objects.
		# It will attempt to dump the object using the given format, but if it fails, it will generate a safe version of the object.
		class Safe
			def initialize(format: ::JSON, limit: 8, encoding: ::Encoding::UTF_8)
				@format = format
				@limit = limit
				@encoding = encoding
			end
			
			def dump(object)
				@format.dump(object, @limit)
			rescue SystemStackError, StandardError => error
				@format.dump(safe_dump(object, error))
			end
			
			private
			
			def filter_backtrace(error)
				frames = error.backtrace
				filtered = {}
				filtered_count = nil
				skipped = nil
				
				frames = frames.filter_map do |frame|
					if filtered[frame]
						if filtered_count == nil
							filtered_count = 1
							skipped = frame.dup
						else
							filtered_count += 1
							nil
						end
					else
						if skipped
							if filtered_count > 1
								skipped.replace("[... #{filtered_count} frames skipped ...]")
							end
							
							filtered_count = nil
							skipped = nil
						end
						
						filtered[frame] = true
						frame
					end
				end
				
				if skipped && filtered_count > 1
					skipped.replace("[... #{filtered_count} frames skipped ...]")
				end
				
				return frames
			end
			
			def safe_dump(object, error)
				object = safe_dump_recurse(object)
				
				object[:truncated] = true
				object[:error] = {
					class: safe_dump_recurse(error.class.name),
					message: safe_dump_recurse(error.message),
					backtrace: safe_dump_recurse(filter_backtrace(error)),
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
			
			def default_objects
				Hash.new.compare_by_identity
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
	end
end
