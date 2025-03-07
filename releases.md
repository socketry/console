# Releases

## v1.30.0

### Introduce `Console::Config` for fine grained configuration.

Introduced a new explicit configuration interface via config/console.rb to enhance logging setup in complex applications. This update gives the application code an opportunity to load files if required and control aspects such as log level, output, and more. Users can override default behaviors (e.g., make\_output, make\_logger, and log\_level) for improved customization.

``` ruby
# config/console.rb
def log_level(env = ENV)
	# Set a custom log level, e.g., force debug mode:
	:debug
end

def make_logger(output = $stderr, env = ENV, **options)
	# Custom logger configuration with verbose output:
	options[:verbose] = true
	
	 Logger.new(output, **options)
end
```

This approach provides a standard way to hook into the log setup process, allowing tailored adjustments for reliable and customizable logging behavior.

## v1.29.3

  - Serialized output now uses `IO#write` with a single string to reduce the chance of interleaved output.

## v1.29.2

  - Always return `nil` from `Console::Filter` logging methods.

## v1.29.1

  - Fix logging `exception:` keyword argument when the value was not an exception.

## v1.29.0

  - Don't make `Kernel#warn` redirection to `Console.warn` the default behavior, you must `require 'console/warn'` to enable it.
  - Remove deprecated `Console::Logger#failure`.

### Consistent handling of exceptions.

`Console.call` and all wrapper methods will now consistently handle exceptions that are the last positional argument or keyword argument. This means that the following code will work as expected:

``` ruby
begin
rescue => error
	# Last positional argument:
	Console.warn(self, "There may be an issue", error)
	
	# Keyword argument (preferable):
	Console.error(self, "There is an issue", exception: error)
end
```

## v1.28.0

  - Add support for `Kernel#warn` redirection to `Console.warn`.
