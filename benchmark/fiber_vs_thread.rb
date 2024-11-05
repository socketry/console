#!/usr/bin/env ruby
# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require "benchmark/ips"
require "fiber"

# GC.disable

puts RUBY_VERSION

class Fiber
	attr_accessor :my_local
end

class MyObject
	attr_accessor :my_local
end

Benchmark.ips do |benchmark|
	benchmark.report("Hash\#[]=") do |count|
		hash = Hash.new
		
		while count > 0
			hash[:my_local] = count
			
			count -= 1
		end
	end
	
	benchmark.report("Thread\#[]=") do |count|
		thread = Thread.current
		
		while count > 0
			thread[:my_local] = count
			
			count -= 1
		end
	end
	
	benchmark.report("Thread\#thread_variable_set") do |count|
		thread = Thread.current
		
		while count > 0
			thread.thread_variable_set(:my_local, count)
			
			count -= 1
		end
	end
	
	benchmark.report("Fiber\#my_local=") do |count|
		fiber = Fiber.current
		
		while count > 0
			fiber.my_local = count
			
			count -= 1
		end
	end
	
	benchmark.report("MyObject\#my_local=") do |count|
		object = MyObject.new
		
		while count > 0
			object.my_local = count
			
			count -= 1
		end
	end
	
	benchmark.compare!
end
