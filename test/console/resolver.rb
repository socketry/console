# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2022, by Samuel Williams.
# Copyright, 2021, by Robert Schulze.

require 'console'
require 'console/resolver'
require 'resolver_classes'

describe Console::Resolver do
	let(:resolver) {subject.new}
	
	it "triggers when class is defined" do
		resolved = false
		
		resolver.bind(["Console::Resolver::Foobar"]) do |klass|
			resolved = true
		end
		
		expect(resolver).to be(:waiting?)
		
		class Console::Resolver::Foobar
		end
		
		expect(resolver).not.to be(:waiting?)
		expect(resolved).to be == true
	end
	
	it "triggers immediately if class is already defined" do
		resolved = false
		
		resolver.bind(["Console::Resolver"]) do |klass|
			resolved = true
		end
		
		expect(resolver).not.to be(:waiting?)
		expect(resolved).to be == true
	end
	
	describe '.default_resolver' do
		let(:logger) {Console.logger}
		
		it 'has no resolver if not required by environment' do
			expect(Console::Resolver.default_resolver(logger)).to be_nil
		end
		
		it 'can set custom log levels from environment' do
			expect(Console::Resolver.default_resolver(logger, {'CONSOLE_WARN' => 'Acorn,Banana', 'CONSOLE_DEBUG' => 'Cat'})).to be_a Console::Resolver
			
			expect(Console.logger.subjects[Acorn]).to be == Console::Logger::WARN
			expect(Console.logger.subjects[Banana]).to be == Console::Logger::WARN
			expect(Console.logger.subjects[Cat]).to be == Console::Logger::DEBUG
		end

		it 'can set "all" and "off" by environment' do
			expect(Console::Resolver.default_resolver(logger, {
				'CONSOLE_ON' => 'Cat',
				'CONSOLE_WARN' => 'Dog',
				'CONSOLE_OFF' => 'Acorn,Banana'
			})).to be_a Console::Resolver
			
			expect(Console.logger.subjects[Acorn]).to be == nil
			expect(Console.logger.subjects[Banana]).to be == nil
			expect(Console.logger.subjects[Cat]).to be == Console::Logger::MINIMUM_LEVEL - 1
			expect(Console.logger.subjects[Dog]).to be == Console::Logger::WARN
		end
	end
end
