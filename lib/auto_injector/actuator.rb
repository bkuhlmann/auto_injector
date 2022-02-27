# frozen_string_literal: true

module AutoInjector
  # Associates the container with the constructor for potential actualization.
  class Actuator
    def initialize container, constructor: AutoInjector::Constructor
      @container = container
      @constructor = constructor
    end

    def [](*keys) = constructor.new container, *keys

    private

    attr_reader :container, :constructor
  end
end
