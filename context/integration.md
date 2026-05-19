# Integration

This guide explains how to integrate the `console` output into different systems.

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

## Adapters

- [Console::Adapter::Rails](https://github.com/socketry/console-adapter-rails)
- [Console::Adapter::Sidekiq](https://github.com/socketry/console-adapter-sidekiq)
