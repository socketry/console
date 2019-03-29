# Global Logger

Configure what logging looks like globally:

```ruby
Console.logger
```

Other logger instances would inherit their initial configuration from the global logger.

Rather than the output being configurable on the global logger, it would always route to `$stdout`. _Or perhaps no destinations should exist and you add one; there must be a way to attach a formatter to even the default destination._

# Adding Destinations

The global logger or any instance could log to multiple destinations:

```ruby
Console.add(some_io, formatter: some_formatter)
```

I _think_ that formatters would be defined on destinations. This would allow for writing in one format to `$stdout` and another to `syslog`, for example.

# Logger Instances

Named instances could be created with a given output:

```ruby
connection_logger = Console.new(:connection, output: ...)
```

Outputs would not reference an io object, but rather another named instance (defaulting to global). Again, Destinations + Formatters could be added to any instance. This would allow outputs to be chained.

## Instances As Subjects

Perhaps an interesting idea is letting logger instance names be subjects, controllable from the global logger. In the example above, `:connection` would become a known subject that could be enabled/disabled from the global logger:

```ruby
Console.disable(:connection)
```

This lets us very easily disable the logging of events of a particular type.

---

In [Pakyow's logger](https://gist.github.com/bryanp/0329d58c753f1fa6e99d970960ad006d#file-logger-rb), instances are created in these cases:

* Environment: Single logger for the environment, named `:pkyw`.
* Connection: Per-Request logger containing the connection id, named `:http`.
* WebSocket: Per-WebSocket logger containing the WebSocket id, named `:sock`.
* Async: The logger that async is configured with, named `:asnc`.

Instances could be initialized with metadata that is passed with the console to the formatter:

```ruby
connection_logger = Console.new(:http, output: ..., connection_id: "123")
```

# Formatters

Just a class with a `format` method that accepts an `console`, which is a hash or simple object containing the console data along with attached metadata (e.g. timestamp, metadata from the instance). Returns a string, and/or writes directly to the buffer.

# Custom Levels

Pakyow's logger uses the following levels:

* all
* verbose
* debug
* info
* warn
* error
* fatal
* unknown
* off

`all` and `off` aren't turned into logging methods in `Pakyow::Logger`, but rather the log level can be set to either one as an easy way to guarantee that all or no logs will be written, without knowing what the lowest and highest level of logging are in the system.

Projects often have different needs, so making this easily configurable on both the global logger and individual logger instances would be amazing:

```ruby
Console.levels(
  %i(all verbose debug info warn error fatal unknown off)
)
```
