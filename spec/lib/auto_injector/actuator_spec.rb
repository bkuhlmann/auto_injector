# frozen_string_literal: true

require "spec_helper"

RSpec.describe AutoInjector::Actuator do
  subject(:actuator) { described_class.new({a: 1, b: 2, c: 3}) }

  before { stub_const "Test::Import", actuator }

  describe "#[]" do
    let(:child) { Class.new.include Test::Import[:a, :b, :c] }

    it "answers injected dependencies" do
      expect(child.new.inspect).to include("@a=1, @b=2, @c=3")
    end
  end
end
