# frozen_string_literal: true

require "marameters"

module AutoInjector
  # Provides the automatic and complete resolution of all injected dependencies.
  # :reek:TooManyInstanceVariables
  class Constructor < Module
    def initialize container, *keys, marameters: Marameters::Core
      super()

      @container = container
      @keys = keys.map(&:to_sym)
      @marameters = marameters
      @class_module = Class.new(Module).new
      @instance_module = Class.new(Module).new
    end

    def included klass
      super
      define klass
      klass.extend class_module
      klass.public_send :include, instance_module
    end

    private

    attr_reader :container, :keys, :marameters, :class_module, :instance_module

    def define klass
      define_new
      define_initialize klass
      define_readers
    end

    def define_new
      class_module.class_exec container, keys do |container, keys|
        define_method :new do |*positionals, **keywords, &block|
          keys.each { |key| keywords[key] = container[key] unless keywords.key? key }
          super(*positionals, **keywords, &block)
        end
      end
    end

    def define_initialize klass
      super_parameters = marameters.of(klass, :initialize).map do |instance|
        break instance unless instance.unnamed_splats_only?
      end

      if super_parameters.positional? || super_parameters.named_single_splat_only?
        define_initialize_with_positionals super_parameters
      else
        define_initialize_with_keywords super_parameters
      end
    end

    def define_initialize_with_positionals super_parameters
      instance_module.class_exec keys, method(:define_variables) do |keys, variable_definer|
        define_method :initialize do |*args, **keywords, &block|
          variable_definer.call self, keywords

          if super_parameters.named_single_splat_only?
            super(*args, **keywords, &block)
          else
            super(*args, **super_parameters.slice(keywords, keys:), &block)
          end
        end
      end
    end

    def define_initialize_with_keywords super_parameters
      instance_module.class_exec keys, method(:define_variables) do |keys, variable_definer|
        define_method :initialize do |**keywords, &block|
          variable_definer.call self, keywords
          super(**super_parameters.slice(keywords, keys:), &block)
        end
      end
    end

    # :reek:FeatureEnvy
    def define_variables target, keywords
      keys.each do |key|
        next unless keywords.key?(key) || !target.instance_variable_defined?(:"@#{key}")

        target.instance_variable_set :"@#{key}", keywords[key]
      end
    end

    def define_readers
      methods = keys.map { |key| ":#{key}" }

      instance_module.class_eval <<-READERS, __FILE__, __LINE__ + 1
        private attr_reader #{methods.join ", "}
      READERS
    end
  end
end
