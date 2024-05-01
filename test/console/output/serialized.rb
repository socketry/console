# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2023, by Samuel Williams.
# Copyright, 2023, by Felix Yan.

require 'console/output/serialized'
require 'console/event/spawn'

describe Console::Output::Serialized do
	let(:io) {StringIO.new}
	let(:logger) {subject.new(io: io)}
	
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
			logger.call(subject, **event)
			
			expect(record).to have_keys(
				subject: be == subject.name,
				event: be == "spawn",
				arguments: be == ["ls -lah"],
			)
		end
	end
	
	with "Fiber annotation" do
		it "logs fiber annotations" do
			Fiber.new do
				Fiber.annotate("Running in a fiber.")
				
				logger.call(message)
			end.resume
			
			expect(record).to have_keys(
				annotation: be == "Running in a fiber.",
				subject: be == "Hello World",
			)
		end
		
		it "logs fiber annotations when it isn't a string" do
			thing = ["Running in a fiber."]
			
			Fiber.new do
				Fiber.annotate(thing)
				
				logger.call(message)
			end.resume
			
			expect(record).to have_keys(
				annotation: be == thing,
				subject: be == "Hello World",
			)
		end
	end
end
