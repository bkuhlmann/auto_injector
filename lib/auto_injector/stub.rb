# frozen_string_literal: true

require "auto_injector"

module AutoInjector
  # Provides stubbing of the injected container when used in a test framework.
  module Stub
    refine Actuator do
      def stub_with(pairs, &)
        return unless block_given?

        container.is_a?(Hash) ? stub_hash_with(pairs, &) : stub_container_with(pairs, &)
      end

      def stub(pairs) = container.is_a?(Hash) ? stub_hash(pairs) : stub_container(pairs)

      def unstub(pairs) = container.is_a?(Hash) ? unstub_hash : unstub_container(pairs)

      private

      def stub_container_with pairs
        stub_container pairs
        yield
        unstub_container pairs
      end

      def stub_container pairs
        container.enable_stubs!
        pairs.each { |key, value| container.stub key, value }
      end

      def unstub_container(pairs) = pairs.each_key { |key| container.unstub key }

      def stub_hash_with pairs
        stub_hash pairs
        yield
        unstub_hash
      end

      def stub_hash pairs
        @backup = container.dup
        container.merge! pairs
      end

      def unstub_hash = container.replace @backup
    end
  end
end
