# Copyright, 2019, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

require 'io/console'

module Console
	# Styled terminal output.
	module Terminal
		class Text
			def initialize(output)
				@output = output
				@styles = {}
			end
			
			def [] key
				@styles[key]
			end
			
			def []= key, value
				@styles[key] = value
			end
			
			def colors?
				false
			end
			
			def style(foreground, background = nil, *attributes)
			end
			
			def reset
			end
			
			def write(*args, style: nil)
				if style and prefix = self[style]
					@output.write(prefix)
					@output.write(*args)
					@output.write(self.reset)
				else
					@output.write(*args)
				end
			end
			
			def puts(*args, style: nil)
				if style and prefix = self[style]
					@output.write(prefix)
					@output.puts(*args)
					@output.write(self.reset)
				else
					@output.puts(*args)
				end
			end
		end
	end
end
