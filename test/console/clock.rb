# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2024, by Samuel Williams.
# Copyright, 2026, by William T. Nelson.

require "console/clock"

describe Console::Clock do
	with ".formatted_duration" do
		it "can format seconds" do
			expect(subject.formatted_duration(0)).to be == "0.00s"
			expect(subject.formatted_duration(0.5)).to be == "0.50s"
			expect(subject.formatted_duration(0.667)).to be == "0.67s"
			expect(subject.formatted_duration(1)).to be == "1.00s"
			expect(subject.formatted_duration(2)).to be == "2.00s"
			expect(subject.formatted_duration(10)).to be == "10.00s"
			expect(subject.formatted_duration(59)).to be == "59.00s"
			expect(subject.formatted_duration(59.999)).to be == "60.00s"
		end
		
		it "can format minutes" do
			expect(subject.formatted_duration(60)).to be == "1m00s"
			expect(subject.formatted_duration(61)).to be == "1m01s"
			expect(subject.formatted_duration(61.999)).to be == "1m01s"
			expect(subject.formatted_duration(120)).to be == "2m00s"
			expect(subject.formatted_duration(600)).to be == "10m00s"
			expect(subject.formatted_duration(3599.999)).to be == "59m59s"
			expect(subject.formatted_duration(3599)).to be == "59m59s"
		end
		
		it "can format hours" do
			expect(subject.formatted_duration(3600)).to be == "1h00m"
			expect(subject.formatted_duration(3601)).to be == "1h00m"
			expect(subject.formatted_duration(7200)).to be == "2h00m"
			expect(subject.formatted_duration(36000)).to be == "10h00m"
			expect(subject.formatted_duration(86399.999)).to be == "23h59m"
			expect(subject.formatted_duration(86399)).to be == "23h59m"
		end
		
		it "can format days" do
			expect(subject.formatted_duration(86400)).to be == "1d00h"
			expect(subject.formatted_duration(86401)).to be == "1d00h"
			expect(subject.formatted_duration(172800)).to be == "2d00h"
			expect(subject.formatted_duration(604799)).to be == "6d23h"
			expect(subject.formatted_duration(864000)).to be == "10d00h"
		end
		
		it "can format many days" do
			expect(subject.formatted_duration(8640000 - 1)).to be == "99d23h"
			expect(subject.formatted_duration(8640000)).to be == "100d"
			expect(subject.formatted_duration(86400000)).to be == "1000d"
		end
	end
	
	with ".now" do
		it "can measure time" do
			expect(subject.now).to be_a(Float)
		end
	end
end
