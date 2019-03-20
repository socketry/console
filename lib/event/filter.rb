# Copyright, 2017, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

require_relative 'buffer'

module Event
	UNKNOWN = 'unknown'
	
	class Filter
		def self.[] **levels
			klass = Class.new(self)
			
			klass.instance_exec do
				const_set(:LEVELS, levels)
				const_set(:MAXIMUM_LEVEL, levels.values.max)
			
				levels.each do |name, level|
					const_set(name.to_s.upcase, level)
					
					define_method(name) do |subject = nil, *arguments, &block|
						enabled = @subjects[subject.class]
						
						if enabled == true or (enabled != false and level >= @level)
							self.call(subject, *arguments, severity: name, **@options, &block)
						end
					end
					
					define_method("#{name}!") do
						@level = level
					end
					
					define_method("#{name}?") do
						@level >= level
					end
				end
			end
			
			return klass
		end
		
		def initialize(output, verbose: true, level: 0, **options)
			@level = level
			@verbose = verbose
			
			@subjects = {}
			
			@output = output
			@options = options.freeze
		end
		
		attr :level
		attr :verbose
		
		attr :subjects
		
		attr :output
		attr :options
		
		def level= level
			if level.is_a? Symbol
				@level = self.class::LEVELS[level]
			else
				@level = level
			end
		end
		
		def verbose!
			@verbose = true
		end
		
		def off!
			@level = -1
		end
		
		def all!
			@level = self.class::MAXIMUM_LEVEL
		end
		
		def enabled?(subject)
			@subjects[subject.class] == true
		end
		
		def enable(subject)
			@subjects[subject.class] = true
		end
		
		def disable(subject)
			@subjects[subject.class] = false
		end
		
		def call(*arguments, &block)
			@output.call(*arguments, &block)
		end
	end
end
