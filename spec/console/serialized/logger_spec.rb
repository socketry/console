# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2021, by Samuel Williams.

require 'console/serialized/logger'

RSpec.describe Console::Serialized::Logger do
	let(:io) {StringIO.new}
	subject{described_class.new(io)}
	
	let(:message) {"Hello World"}
	
	let(:record) {JSON.parse(io.string, symbolize_names: true)}
	
	it "can log to buffer" do
		subject.call do |buffer|
			buffer << message
		end
		
		expect(record).to include :message
		expect(record[:message]).to be == message
	end
	
	it "can log options" do
		subject.call(name: "request-id")
		
		expect(record).to include(:name)
		expect(record[:name]).to be == "request-id"
	end
	
	context 'with structured event' do
		let(:event) {Console::Event::Spawn.for("ls -lah")}
		
		before do
			subject.call(event)
		end
		
		it "can log structured events" do
			expect(record).to include(:subject)
			expect(record[:subject]).to be == ["Console::Event::Spawn", {:arguments => ["ls -lah"]}]
		end
	end
	
	context 'with exception' do
		let(:error) {record[:error]}
		
		before do
			begin
				raise "Boom"
			rescue => error
				subject.call(self, error)
			end
		end
		
		it "can log excepion message" do
			expect(error).to include(:kind, :message, :stack)
		end
	end
end
