# Getting Started

This guide explains how to use `console` for logging.

## Installation

Add the gem to your project:

~~~ bash
$ bundle add console
~~~

## Core Concepts

`console` has several core concepts:

- A log message which consists of a set of arguments and options, which includes a timestamp, severity, and other structured data.
- A {ruby Console::Logger} instance which is the main entry point for logging for a specific system and writes data to a given output formatter.
- An output instance such as {ruby Console::XTerm}, {ruby Console::Serialized::Logger} which formats these log messages and writes them to a specific output device.
- An event instance, such as {ruby Console::Event::Progress} or {ruby Console::Event::Spawn} which represents a structured event within a system, which can be formatted in a specific way.

## Basic Logging

Out of the box, {ruby Console.logger} is a globally shared logger that outputs to the current terminal via `stderr`.

~~~ ruby
require 'console'

Console.logger.info("Hello World")
~~~

<pre>
<font color="#00AA00">  0.0s     info:</font> <b>Hello World</b> <font color="#717171">[pid=219113] [2020-08-08 12:21:26 +1200]</font>
</pre>

The method name `info` indicates the severity level of the log message. You can filter out severity levels, and by default, `debug` messages are filtered out. Here are some examples of the different log levels:

~~~ ruby
require 'console'

Console.logger.debug("The input voltage has stabilized.")
Console.logger.info("Making a request to the machine.")
Console.logger.warn("The machine has detected a temperature anomaly.")
Console.logger.error("The machine was unable to complete the request!")
Console.logger.fatal("Depressurisation detected, evacuate the area!")
~~~

From the terminal, you can control the log level using the `CONSOLE_LEVEL` environment variable. To log all messages including `debug`:

~~~ bash
$ CONSOLE_LEVEL=debug ./machine
~~~

Alternatively to restrict log messages to warnings and above:

~~~ bash
$ CONSOLE_LEVEL=warn ./machine
~~~

If otherwise unspecified, Ruby's standard `$DEBUG` and `$VERBOSE` global variables will be checked and adjust the log level appropriately.

## Subject Logging

The first argument to the log statement becomes the implicit subject of the log message.

~~~ ruby
require 'console'

class Machine
	include Console
	
	def initialize(voltage)
		@voltage = voltage.floor
		logger.info(self, "The input voltage has stabilized.")
	end
end

Machine.new(5.5)
~~~

The given subject, in this case `self`, is used on the first line, along with associated metadata, while the message itself appears on subsequent lines:

<pre>
<font color="#00AA00">  0.0s     info:</font> <b>Machine</b> <font color="#717171">[oid=0x3c] [pid=219041] [2020-08-08 12:17:33 +1200]</font>
               | The input voltage has stabilized.
</pre>

If you want to disable log messages which come from this particular class, you can execute your command:

~~~ bash
$ CONSOLE_FATAL=Machine ./machine
~~~

This will prevent any log message which has a subject of class `Machine` from logging messages of a severity less than `fatal`.

## Exception Logging

If your code has an unhandled exception, you may wish to log it. In order to log a full backtrace, you must log the subject followed by the exception.

~~~ ruby
require 'console'

class Cache
	include Console
	
	def initialize
		@entries = {}
	end
	
	def fetch(key)
		@entries.fetch(key)
	rescue => error
		logger.failure(self, error)
	end
end

Cache.new.fetch(:foo)
~~~

This will produce the following output:

<pre><font color="#AA0000">  0.0s    fatal:</font> <b>Cache</b> <font color="#717171">[oid=0x3c] [pid=220776] [2020-08-08 14:10:00 +1200]</font>
               |   <font color="#AA0000"><b>KeyError</b></font>: key not found: :foo
               |   → <font color="#AA0000">cache.rb:11</font> in &apos;fetch&apos;
               |     <font color="#AA0000">cache.rb:11</font> in &apos;fetch&apos;
               |     <font color="#AA0000">cache.rb:17</font> in &apos;&lt;main&gt;&apos;
</pre>

## Program Structure

Generally, all programs should use the global `Console.logger` instance.

The per-class `include Console` allows you to 

All programs should generally use the global `Console.logger` instance.

Generally, individual classes should not be catching and logging exceptions.

Generally, individual classes should not be catching and logging exceptions. It makes for simpler code if this is handled in a few places near the top of your program. Exceptions should collect enough information such that logging them produces a detailed backtrace leading to the failure.