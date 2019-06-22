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

require_relative 'filter'

module Console
	class Resolver
		def initialize
			@names = {}
			
			@trace_point = TracePoint.new(:class, &self.method(:resolve))
		end
		
		def bind(names, &block)
			names.each do |name|
				if klass = Object.const_get(name) rescue nil
					yield klass
				else
					@names[name] = block
				end
			end
			
			if @names.any?
				@trace_point.enable
			else
				@trace_point.disable
			end
		end
		
		def waiting?
			@trace_point.enabled?
		end
		
		def resolve(trace_point)
			if block = @names.delete(trace_point.self.to_s)
				block.call(trace_point.self)
			end
			
			if @names.empty?
				@trace_point.disable
			end
		end
	end
end
