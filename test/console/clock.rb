# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2024, by Samuel Williams.

require "console/clock"

describe Console::Clock do
	with ".formatted_duration" do
		it "can format seconds" do
			expect(subject.formatted_duration(0)).to be == "0s"
			expect(subject.formatted_duration(1)).to be == "1s"
			expect(subject.formatted_duration(2)).to be == "2s"
			expect(subject.formatted_duration(10)).to be == "10s"
			expect(subject.formatted_duration(59)).to be == "59s"
		end
		
		it "can format minutes" do
			expect(subject.formatted_duration(60)).to be == "1m"
			expect(subject.formatted_duration(61)).to be == "1m"
			expect(subject.formatted_duration(120)).to be == "2m"
			expect(subject.formatted_duration(600)).to be == "10m"
			expect(subject.formatted_duration(3599)).to be == "59m"
		end
		
		it "can format hours" do
			expect(subject.formatted_duration(3600)).to be == "1h"
			expect(subject.formatted_duration(3601)).to be == "1h"
			expect(subject.formatted_duration(7200)).to be == "2h"
			expect(subject.formatted_duration(36000)).to be == "10h"
			expect(subject.formatted_duration(86399)).to be == "23h"
		end
		
		it "can format days" do
			expect(subject.formatted_duration(86400)).to be == "1d"
			expect(subject.formatted_duration(86401)).to be == "1d"
			expect(subject.formatted_duration(172800)).to be == "2d"
			expect(subject.formatted_duration(604799)).to be == "6d"
			expect(subject.formatted_duration(864000)).to be == "10d"
		end
	end
	
	with ".now" do
		it "can measure time" do
			expect(subject.now).to be_a(Float)
		end
	end
end
