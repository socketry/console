# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "console/output/wrapper"

class WrapperDelegate
	attr :verbose
	attr :calls
	
	def initialize
		@calls = []
	end
	
	def last_output
		:self
	end
	
	def verbose!(value = true)
		@verbose = value
	end
	
	def call(*arguments, **options)
		@calls << [arguments, options]
	end
end

describe Console::Output::Wrapper do
	let(:delegate) {WrapperDelegate.new}
	let(:wrapper) {subject.new(delegate)}
	
	it "exposes its delegate" do
		expect(wrapper.delegate).to be == delegate
	end
	
	it "returns the delegate last output" do
		expect(wrapper.last_output).to be == :self
	end
	
	it "forwards verbose changes" do
		wrapper.verbose!(false)
		
		expect(delegate.verbose).to be == false
	end
	
	it "forwards calls" do
		wrapper.call("Hello", name: "test")
		
		expect(delegate.calls).to be == [[ ["Hello"], {name: "test"} ]]
	end
end
