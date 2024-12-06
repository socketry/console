# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2024, by Samuel Williams.
# Copyright, 2019, by Bryan Powell.
# Copyright, 2020, by Michael Adams.

require "console"
require "sus/fixtures/console"

describe Console do
	it "has a version number" do
		expect(Console::VERSION).to be =~ /\d+\.\d+\.\d+/
	end

	it "has interface methods for all log levels" do
		Console::Logger::LEVELS.each do |name, level|
			expect(Console).to be(:respond_to?, name)
		end
	end

	with "an isolated logger" do
		include_context Sus::Fixtures::Console::CapturedLogger

		it "can invoke interface methods for all log levels" do
			Console::Logger::LEVELS.each do |name, level|
				Console.public_send(name, self, "Hello World!", name: "test")

				expect(console_capture.last).to have_keys(
					time: be_a(String),
					severity: be == name,
					subject: be == self,
					arguments: be == ["Hello World!"],
					name: be == "test"
				)
			end
		end

		it "can invoke interface methods for all log levels with block" do
			Console::Logger::LEVELS.each do |name, level|
				Console.public_send(name, self, name: "test") do
					"Hello World!"
				end

				expect(console_capture.last).to have_keys(
					time: be_a(String),
					severity: be == name,
					subject: be == self,
					message: be == "Hello World!",
					name: be == "test"
				)
			end
		end

		it "can invoke interface methods for all log levels with block buffer" do
			Console::Logger::LEVELS.each do |name, level|
				Console.public_send(name, self, name: "test") do |buffer|
					buffer.puts "Hello World!"
				end

				expect(console_capture.last).to have_keys(
					time: be_a(String),
					severity: be == name,
					subject: be == self,
					message: be == "Hello World!\n",
					name: be == "test"
				)
			end
		end

		it "can invoke error with exception" do
			begin
				raise StandardError, "It failed!"
			rescue => error
				Console.error(self, error, name: "test")
			end

			expect(console_capture.last).to have_keys(
				time: be_a(String),
				severity: be == :error,
				subject: be == self,
				name: be == "test",
				event: have_keys(
					type: be == :failure,
					message: be == "It failed!",
				)
			)
		end

		it "can invoke failure with exception" do
			begin
				raise StandardError, "It failed!"
			rescue => error
				Console::Event::Failure.for(error).emit(self, name: "test")
			end

			expect(console_capture.last).to have_keys(
				time: be_a(String),
				severity: be == :error,
				subject: be == self,
				name: be == "test",
				event: have_keys(
					type: be == :failure,
					message: be == "It failed!",
				)
			)
		end

		it "can invoke interface methods with exception key for all log levels" do
			Console::Logger::LEVELS.each do |name, level|
				Console.public_send(name, self, "Hello World!", name: "test", exception: ["test", "value"])

				expect(console_capture.last).to have_keys(
					time: be_a(String),
					severity: be == name,
					subject: be == self,
					arguments: be == ["Hello World!"],
					name: be == "test",
					exception: be == ["test", "value"]
				)
			end
		end
	end

	with "#logger" do
		def before
			@original_logger = subject.logger

			super
		end

		def after(error = nil)
			subject.logger = @original_logger

			super
		end

		it "sets and returns a logger" do
			logger = Console::Logger.new(subject.logger.output)
			subject.logger = logger
			expect(subject.logger).to be(:eql?, logger)
		end
	end
end
