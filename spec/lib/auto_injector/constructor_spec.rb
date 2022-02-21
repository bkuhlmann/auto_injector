# frozen_string_literal: true

require "spec_helper"

RSpec.describe AutoInjector::Constructor do
  before { stub_const "Test::Constructor", described_class.new({eins: 1, zwei: 2}, :eins, :zwei) }

  describe "#included" do
    context "with string keys" do
      let :child do
        Class.new.include described_class.new({eins: 1, zwei: 2}, "eins", "zwei")
      end

      it "answers injected dependencies" do
        expect(child.new.inspect).to include("@eins=1, @zwei=2")
      end
    end

    context "with partially injected dependencies" do
      let(:child) { Class.new.include described_class.new({eins: 1, zwei: 2}, :eins) }

      it "answers specificly injected dependencies" do
        expect(child.new.inspect).to include("@eins=1")
      end

      it "fails when accessing privately injected dependencies" do
        expectation = proc { child.new.eins }
        expect(&expectation).to raise_error(NoMethodError, /private method.+a.+/)
      end
    end

    context "with all possible parameters" do
      let :child do
        Class.new do
          include Test::Constructor

          def initialize one, two = "two", *three, four:, five: 5, **dependencies, &six
            super(**dependencies)

            @one = one
            @two = two
            @three = three
            @four = four
            @five = five
            @six = six
          end

          private

          attr_reader :one, :two, :three, :four, :five, :six
        end
      end

      it "answers injected dependencies" do
        function = proc { "test" }
        instance = child.new(:one, :c, :d, four: 4, &function)

        expect(instance.inspect).to include(
          "@eins=1, @zwei=2, @one=:one, @two=:c, @three=[:d], @four=4, @five=5, @six=#<Proc"
        )
      end
    end

    context "with all possible inherited parameters" do
      let :parent do
        Class.new do
          def initialize one, two = "two", *three, four:, five: 5, **six, &seven
            @one = one
            @two = two
            @three = three
            @four = four
            @five = five
            @six = six
            @seven = seven
          end

          def to_a = [one, two, three, four, five, six, seven]

          private

          attr_reader :one, :two, :three, :four, :five, :six, :seven
        end
      end

      let :child do
        Class.new parent do
          include Test::Constructor

          def initialize one, two = "two", *three, four:, five: 5, **dependencies, &seven
            super
          end

          def to_a = [eins, zwei, *super]
        end
      end

      it "answers injected dependencies" do
        function = proc { "test" }
        instance = child.new(:one, :two, :three, four: 4, six: 6, &function)

        expect(instance.to_a).to eq([1, 2, :one, :two, [:three], 4, 5, {six: 6}, function])
      end
    end

    context "with parent and no parameters" do
      let :parent do
        Class.new do
          def initialize
            @obscured = :obscured
          end

          protected

          attr_reader :obscured
        end
      end

      let(:child) { Class.new(parent).include Test::Constructor }

      it "answers injected dependencies plus parent instance variable" do
        expect(child.new.inspect).to include("@eins=1, @zwei=2, @obscured=:obscured")
      end
    end

    context "with parent and different arguments" do
      let :parent do
        Class.new do
          def initialize other
            @other = other
          end

          protected

          attr_reader :other
        end
      end

      let(:child) { Class.new(parent).include Test::Constructor }

      it "answers injected dependencies plus child to parent dependency" do
        expect(child.new(:other).inspect).to include("@eins=1, @zwei=2, @other=:other")
      end
    end

    context "with parent and named single splat" do
      let :parent do
        Class.new do
          def initialize *any
            @any = any
          end

          protected

          attr_reader :any
        end
      end

      let(:child) { Class.new(parent).include Test::Constructor }

      it "answers injected dependencies plus splatted dependencies from child" do
        instance = child.new :one, :two

        expect(instance.inspect).to include(
          "@eins=1, @zwei=2, @any=[:one, :two, {:eins=>1, :zwei=>2}]"
        )
      end
    end

    context "with parent and keyword arguments (optional and splat)" do
      let :parent do
        Class.new do
          def initialize eins: :unknown, **rest
            @first = eins
            @rest = rest
          end

          private

          attr_reader :first, :rest
        end
      end

      let(:child) { Class.new(parent).include Test::Constructor }

      it "answers matched overridden dependency and includes keyword splat" do
        instance = child.new eins: :one, zwei: 2, c: 3
        expect(instance.inspect).to include("@eins=:one, @zwei=2, @first=:one, @rest={:c=>3}")
      end
    end

    context "with multiple inheritance using unnamed single splat" do
      let :child do
        mod = Module.new { def initialize(*) = super }

        Class.new do
          include mod
          include Test::Constructor
        end
      end

      it "answers injected dependencies" do
        expect(child.new.inspect).to include("@eins=1, @zwei=2")
      end
    end

    context "with multiple inheritance using unnamed double splat" do
      let :child do
        mod = Module.new { def initialize(**) = super }

        Class.new do
          include mod
          include Test::Constructor
        end
      end

      it "answers injected dependencies" do
        expect(child.new.inspect).to include("@eins=1, @zwei=2")
      end
    end

    context "with multiple inheritance using unnamed single and double splats" do
      let :child do
        mod = Module.new { def initialize(*, **) = super }

        Class.new do
          include mod
          include Test::Constructor
        end
      end

      it "answers injected dependencies" do
        expect(child.new.inspect).to include("@eins=1, @zwei=2")
      end
    end

    context "with inheritance and parent injections only" do
      let(:parent) { Class.new.include described_class.new({a: 1, b: 2}, :a, :b) }
      let(:child) { Class.new(parent).include Test::Constructor }

      it "answers child preferred injected dependencies" do
        expect(child.new.inspect).to include("@eins=1, @zwei=2")
      end
    end

    context "with inheritance and mixed injections" do
      let(:parent) { Class.new.include described_class.new({a: 1, b: 2}, :a, :b) }
      let(:child) { Class.new(parent).include described_class.new({a: 3, b: 4}, :b) }

      it "answers child preferred injected dependencies" do
        expect(child.new.inspect).to include("@b=4, @a=1")
      end
    end
  end
end
