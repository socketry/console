require 'stackprof'
require_relative 'lib/console'

StackProf.run(mode: :cpu, interval: 10, out: 'profile.stackprof') do
  100_000.times do
		Console.logger.info self, "Hello World"
	end
end