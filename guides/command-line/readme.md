# Command Line

This guide explains how the `console` gem can be controlled using environment variables.

## Environment Variables

The following program, `app.rb` will be used to explain the different environmet variables:

~~~ ruby
#!/usr/bin/env ruby

require 'console'

class MyApplication
	def do_work
		Console.logger.debug(self, "Doing some work.")
	end
end

Console.logger.debug(self, "Creating the application.")
application = MyApplication.new
application.do_work
~~~

### `CONSOLE_LEVEL=debug`

Control the default logger level. You can set it to any of the supported log levels: `debug`, `info`, `warn`, `error`, `fatal`.

By default, the debug level is not enabled, but you can enable it using `CONSOLE_LEVEL=debug`:

<pre>&gt; <font color="#00AFFF">CONSOLE_LEVEL</font><font color="#00A6B2">=</font><font color="#00AFFF">debug</font> <font color="#005FD7">./app.rb</font>
<font color="#00AAAA">  0.0s    debug:</font> <b>Object</b> <font color="#717171">[oid=0x3c] [ec=0x50] [pid=990900] [2022-10-12 17:28:15 +1300]</font>
               | Creating the application.
<font color="#00AAAA">  0.0s    debug:</font> <b>MyApplication</b> <font color="#717171">[oid=0x64] [ec=0x50] [pid=990900] [2022-10-12 17:28:15 +1300]</font>
               | Doing some work.
</pre>

### `CONSOLE_DEBUG=MyClass,MyModule::MyClass`

Enable debug logging for the specified class names. You can specify one or more class names which will be resolved at runtime. This is specifically related to subject logging.

By default, the debug level is not enabled, but you can enable it for the specific `MyApplication` class using `CONSOLE_DEBUG=MyApplication`:

<pre>&gt; <font color="#00AFFF">CONSOLE_DEBUG</font><font color="#00A6B2">=</font><font color="#00AFFF">MyApplication</font> <font color="#005FD7">./app.rb</font>
<font color="#00AAAA">  0.0s    debug:</font> <b>MyApplication</b> <font color="#717171">[oid=0x64] [ec=0x78] [pid=991855] [2022-10-12 17:30:56 +1300]</font>
               | Doing some work.
</pre>
