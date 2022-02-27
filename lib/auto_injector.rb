# frozen_string_literal: true

require "zeitwerk"

Zeitwerk::Loader.for_gem.setup

# Main namespace.
module AutoInjector
  def self.[](container) = Actuator.new container
end
