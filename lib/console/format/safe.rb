# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2025, by Samuel Williams.

require "json"

module Console
	# @namespace
	module Format
		# A safe format for converting objects to strings.
		# 
		# Handles issues like circular references, encoding errors, excessive nesting depth, and excessive output size.
		class Safe
			# The JSON fragment used as the truncation marker when dropped fields cannot be named.
			TRUNCATED = "\"truncated\":true"
			
			# Create a new safe format.
			#
			# @parameter format [JSON] The format to use for serialization.
			# @parameter depth_limit [Integer] The maximum depth to recurse into objects (the JSON `max_nesting`).
			# @parameter size_limit [Integer | Nil] The maximum byte size of the serialized output, or `nil` to disable size limiting. Limits below {TRUNCATED} (the minimal marker) cannot be honoured.
			# @parameter encoding [Encoding] The encoding to use for strings.
			# @parameter limit [Integer | Nil] Deprecated alias for `depth_limit`.
			def initialize(format: ::JSON, depth_limit: 12, size_limit: 16 * 1024, encoding: ::Encoding::UTF_8, limit: nil)
				if limit
					warn "Console::Format::Safe `limit:` is deprecated, use `depth_limit:` instead.", uplevel: 1, category: :deprecated
					depth_limit = limit
				end
				
				@format = format
				@depth_limit = depth_limit
				@size_limit = size_limit
				@encoding = encoding
			end
			
			# @attribute [Integer] The maximum depth to recurse into objects.
			attr :depth_limit
			
			# @attribute [Integer | Nil] The maximum byte size of the serialized output.
			attr :size_limit
			
			# Dump the given object to a string.
			#
			# The common case is a single fast serialization. If that fails (e.g. circular
			# references, excessive nesting, or encoding errors) or its output exceeds
			# {size_limit}, it falls back to {safe_dump}, which rebuilds the record
			# field-by-field within the limit.
			#
			# @parameter object [Object] The object to dump.
			# @returns [String] The dumped object.
			def dump(object)
				buffer = @format.dump(object, @depth_limit)
				
				if @size_limit and buffer.bytesize > @size_limit
					return safe_dump(object)
				end
				
				return buffer
			rescue SystemStackError, StandardError
				return safe_dump(object)
			end
			
			private
			
			# Produce a safe, size-limited serialization of the given object. This is the
			# fallback path, used both when direct serialization fails (an exception) and
			# when its output exceeds {size_limit}.
			#
			# Each top-level value is serialized independently and defensively, so a single
			# un-serializable or oversized value cannot break or bloat the whole record.
			# Whenever a field is degraded, the reason is recorded in a trailing `"truncated"`
			# object that maps the field name to why it was truncated:
			#
			# - `"key": true` — the value was dropped because it did not fit the size limit.
			# - `"key": {error}` — the value could not be serialized directly; a safe
			#   representation was kept in its place and the triggering error is recorded.
			#
			# Fields are kept while they fit, always reserving room for at least a minimal
			# `"truncated":true` marker. The detailed reason map is then emitted only if it
			# fits in the remaining space; otherwise it degrades to `"truncated":true`. This
			# is best-effort — in the worst case the per-field detail is lost — but it keeps
			# the bookkeeping simple and the size guarantee hard.
			#
			# @parameter object [Object] The object to serialize.
			# @returns [String] The safe, size-limited serialized record.
			def safe_dump(object)
				# Serialize hash-like objects field-by-field; anything else falls through to the
				# error handler below, which emits a minimal truncated marker.
				object = object.to_hash
				
				# Serialize each field once, capturing the error for any value that could not be
				# serialized directly. Our own "truncated" key is skipped so it is never duplicated.
				errors = {}
				fragments = []
				object.each do |key, value|
					name = key.to_s
					next if name == "truncated"
					
					fragment, error = dump_pair(key, value)
					errors[name] = error_info(error) if error
					fragments << [name, fragment]
				end
				
				# Assemble the body, keeping each field while it fits — always reserving room for
				# at least a minimal `"truncated":true` marker. Each truncated field's reason is
				# collected: its error (value recovered) or `true` (dropped for size).
				buffer = +"{"
				first = true
				reasons = {}
				
				fragments.each do |name, fragment|
					if buffer.bytesize + (first ? 0 : 1) + fragment.bytesize + TRUNCATED.bytesize + 2 <= @size_limit
						buffer << "," unless first
						buffer << fragment
						first = false
						
						# The value was kept; if it had to be recovered, note why.
						reasons[name] = errors[name] if errors[name]
					else
						# The value did not fit and was dropped entirely.
						reasons[name] = true
					end
				end
				
				unless reasons.empty?
					# Include the detailed reasons if they fit, otherwise fall back to the minimal
					# marker so the truncation is still signalled.
					detailed = "\"truncated\":#{@format.dump(reasons)}"
					fits = buffer.bytesize + (first ? 0 : 1) + detailed.bytesize + 1 <= @size_limit
					
					buffer << "," unless first
					buffer << (fits ? detailed : TRUNCATED)
				end
				
				buffer << "}"
				
				return buffer
			rescue SystemStackError, StandardError
				return "{#{TRUNCATED}}"
			end
			
			# Serialize a single top-level `"key":value` pair, safely handling values that
			# cannot be serialized directly.
			#
			# @parameter key [Object] The field key.
			# @parameter value [Object] The field value.
			# @returns [Array(String, Exception | Nil)] The `"key":value` fragment and the error, if recovery was needed.
			def dump_pair(key, value)
				value_json, error = dump_value(value)
				
				return ["#{dump_string(String(key))}:#{value_json}", error]
			end
			
			# Serialize a single value, falling back to a safe representation on failure.
			#
			# @parameter value [Object] The value to serialize.
			# @returns [Array(String, Exception | Nil)] The serialized value and the error, if recovery was needed.
			def dump_value(value)
				[@format.dump(value, @depth_limit), nil]
			rescue SystemStackError, StandardError => error
				[@format.dump(safe_dump_recurse(value)), error]
			end
			
			# Serialize a string as a JSON string, encoding it safely first.
			#
			# @parameter value [String] The string to serialize.
			# @returns [String] The serialized (quoted) string.
			def dump_string(value)
				@format.dump(value.encode(@encoding, invalid: :replace, undef: :replace))
			end
			
			# Filter the backtrace to remove duplicate frames and reduce verbosity.
			#
			# @parameter error [Exception] The exception to filter.
			# @returns [Array(String)] The filtered backtrace.
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
			
			# Build a safe, primitive representation of an error for inclusion as an `"error"` field.
			#
			# @parameter error [Exception] The error that occurred while dumping the object.
			# @returns [Hash] The error details (class, message, filtered backtrace).
			def error_info(error)
				{
					class: safe_dump_recurse(error.class.name),
					message: safe_dump_recurse(error.message),
					backtrace: safe_dump_recurse(filter_backtrace(error)),
				}
			end
			
			# Create a new hash with identity comparison.
			def default_objects
				Hash.new.compare_by_identity
			end
			
			# This will recursively generate a safe version of the object. Nested hashes and arrays will be transformed recursively. Strings will be encoded with the given encoding. Primitive values will be returned as-is. Other values will be converted using `as_json` if available, otherwise `to_s`.
			#
			# @parameter object [Object] The object to dump.
			# @parameter limit [Integer] The maximum depth to recurse into objects.
			# @parameter objects [Hash] The objects that have already been visited.
			# @returns [Object] The dumped object as a primitive representation.
			def safe_dump_recurse(object, limit = @depth_limit, objects = default_objects)
				case object
				when Hash
					if limit <= 0 || objects[object]
						return "{...}"
					else
						objects[object] = true
						
						return object.to_h do |key, value|
							[
								String(key).encode(@encoding, invalid: :replace, undef: :replace),
								safe_dump_recurse(value, limit - 1, objects)
							]
						end
					end
				when Array
					if limit <= 0 || objects[object]
						return "[...]"
					else
						objects[object] = true
						
						return object.map do |value|
							safe_dump_recurse(value, limit - 1, objects)
						end
					end
				when String
					return object.encode(@encoding, invalid: :replace, undef: :replace)
				when Numeric, TrueClass, FalseClass, NilClass
					return object
				else
					if limit <= 0 || objects[object]
						return "..."
					else
						objects[object] = true
						
						# We could do something like this but the chance `as_json` will blow up.
						# We'd need to be extremely careful about it.
						# if object.respond_to?(:as_json)
						# 	safe_dump_recurse(object.as_json, limit - 1, objects)
						# else
						return safe_dump_recurse(object.to_s, limit - 1, objects)
					end
				end
			end
		end
	end
end
