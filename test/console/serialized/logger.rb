# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2022, by Samuel Williams.

require 'console/serialized/logger'
require 'console/event/spawn'

describe Console::Serialized::Logger do
	let(:io) {StringIO.new}
	let(:logger) {subject.new(io)}
	
	let(:message) {"Hello World"}
	
	let(:record) {JSON.parse(io.string, symbolize_names: true)}
	
	it "can log to buffer" do
		logger.call do |buffer|
			buffer << message
		end
		
		expect(record).to have_keys(
			message: be == message
		)
	end
	
	it "can log options" do
		logger.call(name: "request-id")
		
		expect(record).to have_keys(
			name: be == "request-id"
		)
	end
	
	with 'structured event' do
		let(:event) {Console::Event::Spawn.for("ls -lah")}
		
		it "can log structured events" do
			logger.call(event)
			
			expect(record).to have_keys(
				subject: be == ["Console::Event::Spawn", {:arguments => ["ls -lah"]}]
			)
		end
	end
	
	with 'exception' do
		let(:error_message) {record[:error]}
		
		it "can log exception message" do
			begin
				raise "Boom"
			rescue => error
				logger.call(self, error)
			end
			
			expect(error_message).to have_keys(:kind, :message, :stack)
		end
	end
end
