# Event

Provides beautiful event logging for Ruby applications. Implements fast, buffered log output.

[![Build Status](https://travis-ci.com/socketry/event.svg)](http://travis-ci.com/socketry/event)
[![Coverage Status](https://coveralls.io/repos/socketry/event/badge.svg)](https://coveralls.io/r/socketry/event)

## Motivation

When Ruby decided to reverse the order of exception backtraces, I finally gave up using the built in logging and decided restore sanity to the output of my programs once and for all!

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'event'
```

And then execute:

	$ bundle

## Usage

Generally speaking, use `Event::Console.logger` which is suitable for logging to the user's event.

### Event

If you don't like the name "Event", you can also use the following:

```ruby
require 'event/console'

# The top level module Event is an alias for Event:
Event::Console.logger
```

The reason for this is because I cannot acquire the gem named "event". "Event" is a play on the word "Terminal".

### Module Integration

```ruby
# Set the log level:
Event::Console.logger.debug!

module MyModule
	extend Event::Console
	
	def self.test_logger
		debug "GOTO LINE 1."
		info "5 things your doctor won't tell you!"
		warn "Something didn't work as expected!"
		error "The matrix has two cats!"
	end
	
	test_logger
end
```

### Class Integration

```ruby
# Set the log level:
Event::Console.logger.debug!

class MyObject
	include Event::Console

	def test_logger
		debug "GOTO LINE 1."
		info "5 things your doctor won't tell you!"
		warn "Something didn't work as expected!"
		error "The matrix has two cats!"
	end
end

MyObject.new.test_logger
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Released under the MIT license.

Copyright, 2019, by [Samuel Williams](https://www.codeotaku.com).

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
