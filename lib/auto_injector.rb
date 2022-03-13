# frozen_string_literal: true

require "zeitwerk"

Zeitwerk::Loader.for_gem.then do |loader|
  loader.ignore "#{__dir__}/auto_injector/stub"
  loader.setup
end

# Main namespace.
module AutoInjector
  def self.[](container) = Actuator.new container
end
