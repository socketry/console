# frozen_string_literal: true

require_relative '../lib/console'

recipe :info, description: "Increase the verbosity of the logger to info." do
	Console.logger.info!
end

recipe :debug, description: "Increase the verbosity of the logger to debug." do
	Console.logger.debug!
end
