# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2021, by Samuel Williams.

require 'console'

RSpec.describe Console do
	it "has a version number" do
		expect(Console::VERSION).not_to be nil
	end
end
