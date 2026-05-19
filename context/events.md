# Events

This guide explains how to log structured events with a well-defined schema.

## Overview

Logs often fall into two categories:

- Free-form logs which include some structured data, but are primarily text-based and used for debugging or troubleshooting.
- Structured logs which are designed to be machine-readable and can be used for monitoring, alerting, auditing and analytics.

Events are a type of structured log which are designed to be machine-readable and have a well-defined schema. They are used to represent a specific occurrence within a system, such as a request, a response, an error, or a warning. You can create custom events to represent any structured data you like.

## Core Concepts

- {ruby Console::Event::Generic} is the base class for all events.
- {ruby Console::Terminal::Formatter} includes a collection of formatters for rendering specific events in a human-readable format.

## Emitting Events

To emit an event, you can create an instance of a specific event class and call the `#emit` method. For example, to emit a failure event:

```ruby
def handle_request
	begin
		# ... user code ...
	rescue => error
		Console::Event::Failure.for(error).emit(self, "Failed to handle request!")
	end
end
```

This will emit a failure event with the error message and backtrace.

### Emitting Events with Different Severity Levels

Events can have different severity levels, such as `:info`, `:warn`, `:error`, and `:fatal`. You can specify the severity level when emitting an event:

```ruby
Console::Event::Failure.for(error).emit(self, "Failed to handle request!", severity: :debug)
```

## Custom Events

You can create custom events by subclassing {ruby Console::Event::Generic} and defining the schema for the event. For example, to create a custom event for tracking user logins:

```ruby
class UserLoginEvent < Console::Event::Generic
	def self.for(request, user)
		self.new(user.id, request.ip)
	end
	
	def new(id, ip)
		@id = id
		@ip = ip
	end
	
	def to_hash
		{
			# Specifying a type field is recommended:
			type: :login,
			
			# Custom fields:
			id: @id,
			ip: @ip
		}
	end
end

UserLoginEvent.for(request, user).emit(self, "User logged in.")
```
