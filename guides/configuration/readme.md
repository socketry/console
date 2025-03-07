# Configuration

This guide explains how to implement per-project configuration for the `console` gem.

## Configuration File

The `console` gem can load a configuration file, by default `config/console.rb`. This file is evaluated in an instance of {ruby Console::Config} which allows you to override methods that implement the default behaviour for a given project.

Here is an example configuration file:

```ruby
# config/console.rb

# Override the default log level
def log_level
	:debug
end

# Override the default output
def make_output
	Console::Output::Datadog.new(Console::Output::Default.new)
end
```
