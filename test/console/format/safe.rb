# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2024, by Samuel Williams.

require "console/logger"
require "console/capture"
require "my_custom_output"

class JSONHash < Hash
	def to_json(options = nil)
		::JSON.generate(self)
	end
end

describe Console::Format::Safe do
	let(:format) {subject.new}
	let(:object) {JSONHash.new}
	
	with SystemStackError do
		let(:frames) {[
			"A",
			"B",
			"C",
			"B",
			"C",
			"D",
			"D",
			"D",
		]}
		
		it "can handle as_json raising SystemStackError" do
			mock(object) do |mock|
				mock.replace(:to_json) do
					raise SystemStackError, "stack level too deep", frames
				end
			end
			
			message = JSON.parse(
				format.dump({broken: object})
			)
			
			# The error is attributed to the specific field whose value could not serialize.
			expect(message).to have_keys(
				"truncated" => have_keys(
					"broken" => have_keys(
						"class" => be == "SystemStackError",
						"message" => be =~ /stack level too deep/,
					)
				)
			)
			
			backtrace = message["truncated"]["broken"]["backtrace"]
			expect(backtrace).to be_a(Array)
			expect(backtrace).to be == [
				"A",
				"B",
				"C",
				"[... 2 frames skipped ...]",
				"D",
				"[... 2 frames skipped ...]",
			]
		end
	end
	
	with StandardError do
		it "can handle as_json raising StandardError" do
			mock(object) do |mock|
				mock.replace(:to_json) do
					raise StandardError, "something went wrong"
				end
			end
			
			message = JSON.parse(
				format.dump({broken: object})
			)
			
			expect(message).to have_keys(
				"truncated" => have_keys(
					"broken" => have_keys(
						"class" => be == "StandardError",
						"message" => be =~ /something went wrong/,
					)
				)
			)
			
			backtrace = message["truncated"]["broken"]["backtrace"]
			expect(backtrace).to be_a(Array)
		end
	end
	
	with "size limiting" do
		let(:format) {subject.new(size_limit: 128)}
		
		it "passes through records within the size limit" do
			line = format.dump({severity: "info", message: "hi"})
			parsed = JSON.parse(line)
			expect(parsed["message"]).to be == "hi"
			expect(parsed["truncated"]).to be_nil
		end
		
		it "drops oversized fields and names them in the marker" do
			line = format.dump({severity: "info", message: "x" * 1024, subject: "short"})
			parsed = JSON.parse(line)
			expect(line.bytesize).to be <= 128
			expect(parsed["severity"]).to be == "info"
			expect(parsed["subject"]).to be == "short"
			expect(parsed["message"]).to be_nil
			# The marker maps the dropped field to its reason (`true` = dropped for size).
			expect(parsed["truncated"]).to be == {"message" => true}
		end
		
		it "keeps as many leading fields as fit when there are many" do
			record = {}
			40.times{|i| record[:"field_#{i}"] = "ab"}
			line = format.dump(record)
			parsed = JSON.parse(line)
			expect(line.bytesize).to be <= 128
			expect(parsed["field_0"]).to be == "ab"
			expect(parsed["field_39"]).to be_nil
			# Truncation is always reported (named fields where they fit, otherwise `true`).
			expect(parsed["truncated"]).not.to be_nil
		end
		
		it "falls back to a boolean marker when dropped names cannot be listed" do
			# A tiny limit leaves no room to name dropped fields, so rather than an empty
			# or misleading list, the marker stays as `true`.
			tiny = subject.new(size_limit: 20)
			line = tiny.dump({aaa: "x" * 50, bbb: "y" * 50})
			expect(line.bytesize).to be <= 20
			expect(JSON.parse(line)["truncated"]).to be == true
		end
		
		it "skips a huge leading value so later small fields survive" do
			line = format.dump({message: "x" * 5000, severity: "info", tag: "a"})
			parsed = JSON.parse(line)
			expect(line.bytesize).to be <= 128
			expect(parsed["severity"]).to be == "info"
			expect(parsed["tag"]).to be == "a"
			expect(parsed["message"]).to be_nil
			expect(parsed["truncated"]).to be == {"message" => true}
		end
		
		it "stays valid and within the limit when the error path also overflows" do
			# A circular reference forces the error path while an oversized field forces size
			# truncation. Under a hard limit, the error details and data compete for space
			# (either may be dropped), but the result is always valid and within the limit,
			# with a single truncation marker.
			record = {severity: "info", payload: "x" * 2000}
			record[:self] = record
			line = format.dump(record)
			expect(line.bytesize).to be <= 128
			expect(JSON.parse(line)["truncated"]).not.to be_nil
			expect(line.scan(/"truncated"/).size).to be == 1
		end
		
		it "returns a minimal marker for oversized non-hash records" do
			# Non-hash records cannot be serialized field-by-field, so they degrade to the
			# minimal truncated marker.
			line = format.dump(["x" * 200] * 5)
			expect(JSON.parse(line)).to be == {"truncated" => true}
		end
		
		it "passes through output that is exactly at the limit" do
			record = {keep: "v", note: "exactly"}
			exact = JSON.dump(record).bytesize
			expect(subject.new(size_limit: exact).dump(record)).to be == JSON.dump(record)
		end
		
		it "truncates when the output is one byte over the limit" do
			record = {keep: "v", drop: "x" * 100}
			over = JSON.dump(record).bytesize - 1
			line = subject.new(size_limit: over).dump(record)
			parsed = JSON.parse(line)
			expect(line.bytesize).to be <= over
			expect(parsed["keep"]).to be == "v"
			expect(parsed["truncated"]).to be == {"drop" => true}
		end
		
		it "keeps every result within the limit across a range of sizes" do
			record = {severity: "info", message: "x" * 200, subject: "short", extra: "y" * 80}
			(18..400).each do |limit|
				line = subject.new(size_limit: limit).dump(record)
				expect(line.bytesize).to be <= limit
				expect(JSON.parse(line)).to be_a(Hash)
			end
		end
		
		it "respects the byte limit with multi-byte characters" do
			# Each "é" is two bytes, so the byte limit must not be confused with length.
			record = {message: "é" * 200, tag: "x"}
			line = subject.new(size_limit: 64).dump(record)
			expect(line.bytesize).to be <= 64
			expect(JSON.parse(line)).to be_a(Hash)
		end
		
		it "emits valid JSON even when the limit is below the minimal marker size" do
			# {"truncated":true} (18 bytes) cannot be made smaller, so limits below it
			# cannot be honoured — but the output is still valid JSON.
			line = subject.new(size_limit: 5).dump({a: "x" * 100})
			expect(JSON.parse(line)).to be == {"truncated" => true}
		end
	end
	
	with "failed fields" do
		it "attributes the error to the field whose value could not be serialized" do
			recursive = {}
			recursive[:loop] = recursive
			line = format.dump({severity: "info", payload: recursive})
			parsed = JSON.parse(line)
			# The offending field is named in `truncated` with its error as the reason.
			expect(parsed["truncated"]["payload"]).to have_keys("class", "message", "backtrace")
			# Its value is still present as a recovered, safe representation.
			expect(parsed["payload"]).not.to be_nil
			# Fields that serialized fine are untouched, and carry no reason.
			expect(parsed["severity"]).to be == "info"
			expect(parsed["truncated"]["severity"]).to be_nil
		end
		
		it "recovers nested primitives and objects within a failed value" do
			# The recovered value exercises the safe recursion over a number, a custom
			# object (converted via to_s), the same object seen twice, and a cycle.
			shared = Object.new
			inner = {count: 1, first: shared, second: shared}
			inner[:loop] = inner
			
			line = format.dump({payload: inner})
			parsed = JSON.parse(line)
			expect(parsed["payload"]["count"]).to be == 1
			expect(parsed["payload"]["loop"]).to be == "{...}"
			expect(parsed["truncated"]["payload"]).not.to be_nil
		end
	end
	
	with "deprecated limit:" do
		it "sets depth_limit and emits a deprecation warning" do
			# `warn` is routed through Console itself, so intercept it at the source.
			expect(Warning).to receive(:warn)
			
			format = subject.new(limit: 5)
			expect(format.depth_limit).to be == 5
		end
	end
	
	with "hash-like records" do
		# A record that is not a Hash but implements the implicit to_hash protocol.
		let(:record) do
			klass = Class.new do
				def initialize(hash) = (@hash = hash)
				def to_hash = @hash
				# Force the fast path to fail so the safe path handles it.
				def to_json(*) = raise("no json")
			end
			klass.new({severity: "info", message: "hello"})
		end
		
		it "serializes hash-like objects field-by-field via to_hash" do
			parsed = JSON.parse(format.dump(record))
			expect(parsed["severity"]).to be == "info"
			expect(parsed["message"]).to be == "hello"
		end
	end
	
	with "size_limit: nil" do
		let(:format) {subject.new(size_limit: nil)}
		
		it "does not truncate regardless of size" do
			line = format.dump({message: "x" * 5000})
			expect(JSON.parse(line)["message"]).to be == "x" * 5000
		end
	end
end
