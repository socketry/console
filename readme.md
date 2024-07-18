# Console

Provides beautiful console logging for Ruby applications. Implements fast, buffered log output.

[![Development Status](https://github.com/socketry/console/workflows/Test/badge.svg)](https://github.com/socketry/console/actions?workflow=Test)

## Motivation

When Ruby decided to reverse the order of exception backtraces, I finally gave up using the built in logging and decided restore sanity to the output of my programs once and for all\!

## Features

  - Thread safe global logger with per-fiber context.
  - Carry along context with nested loggers.
  - Enable/disable log levels per-class.
  - Detailed logging of exceptions.
  - Beautiful logging to the terminal or structured logging using JSON.

## Usage

Please see the [project documentation](https://socketry.github.io/console/) for more details.

  - [Getting Started](https://socketry.github.io/console/guides/getting-started/index) - This guide explains how to use `console` for logging.

  - [Command Line](https://socketry.github.io/console/guides/command-line/index) - This guide explains how the `console` gem can be controlled using environment variables.

  - [Integration](https://socketry.github.io/console/guides/integration/index) - This guide explains how to integrate the `console` output into different systems.

## Contributing

We welcome contributions to this project.

1.  Fork it.
2.  Create your feature branch (`git checkout -b my-new-feature`).
3.  Commit your changes (`git commit -am 'Add some feature'`).
4.  Push to the branch (`git push origin my-new-feature`).
5.  Create new Pull Request.

### Developer Certificate of Origin

In order to protect users of this project, we require all contributors to comply with the [Developer Certificate of Origin](https://developercertificate.org/). This ensures that all contributions are properly licensed and attributed.

### Community Guidelines

This project is best served by a collaborative and respectful environment. Treat each other professionally, respect differing viewpoints, and engage constructively. Harassment, discrimination, or harmful behavior is not tolerated. Communicate clearly, listen actively, and support one another. If any issues arise, please inform the project maintainers.

## See Also

  - [console-adapter-rails](https://github.com/socketry/console-adapter-rails)
  - [console-adapter-sidekiq](https://github.com/socketry/console-adapter-sidekiq)
  - [console-output-datadog](https://github.com/socketry/console-output-datadog)
  - [sus-fixtures-console](https://github.com/sus-rb/sus-fixtures-console)
