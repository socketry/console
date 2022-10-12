# Console

Provides beautiful console logging for Ruby applications. Implements fast, buffered log output.

[![Development Status](https://github.com/socketry/console/workflows/Test/badge.svg)](https://github.com/socketry/console/actions?workflow=Test)

## Motivation

When Ruby decided to reverse the order of exception backtraces, I finally gave up using the built in logging and decided restore sanity to the output of my programs once and for all!

## Features

  - Thread safe global logger with per-fiber context.
  - Carry along context with nested loggers.
  - Enable/disable log levels per-class.
  - Detailed logging of exceptions.
  - Beautiful logging to the terminal or structured logging using JSON.

## Usage

Please see the [project documentation](https://socketry.github.io/console).

## Contributing

We welcome contributions to this project.

1.  Fork it.
2.  Create your feature branch (`git checkout -b my-new-feature`).
3.  Commit your changes (`git commit -am 'Add some feature'`).
4.  Push to the branch (`git push origin my-new-feature`).
5.  Create new Pull Request.
