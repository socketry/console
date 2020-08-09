#!/usr/bin/env ruby
# frozen_string_literal: true

# Copyright, 2020, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'benchmark/ips'
require 'fiber'

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
