# Integration

This guide explains how to redirect the `console` log messages to different backends.

## Output Redirection

The `console` is primarily an interface for logging, with a general purpose implementation which can log to a terminal (human readable) or a file (JSON by default). Output can also be augmented, redirected or manipulated by adding output wrappers. The output wrappers are generally configured using environment variables.

### `Console::Output::Datadog`

This output wrapper augments log messages with trace metadata so that the log messages can be correlated with spans. Note that the default output is still used `Console::Output::Default`.

~~~ bash
$ CONSOLE_OUTPUT='Console::Output::Datadog,Console::Output::Default' ./app.rb
~~~

The `Console::Output::Datadog` is a wrapper that augments the metadata of the log message with the `trace_id` and `span_id`.

### Custom Output Wrapper

It's straight forward to define your own output wrapper:

~~~ ruby
# Add a happy face to all log messages.
class HappyLogger
	def call(subject = nil, *arguments, **options, &block)
		arguments << "😊"
		
		@output.call(subject, *arguments, **options, &block)
	end
end
~~~

## Rails Integration

Rails is a little bit tricky since it expects a `Logger` instance, and reaches into the internal implementation, so we need to monkeypatch it:

~~~ ruby
require 'rails'

require 'console'
require 'console/compatible/logger'

if ActiveSupport::Logger.respond_to?(:logger_outputs_to?)
  # https://github.com/rails/rails/issues/44800
  class ActiveSupport::Logger
    def self.logger_outputs_to?(*)
      true
    end
  end
end

Rails.logger = Console::Compatible::Logger.new("Rails", Console.logger.output)
~~~
