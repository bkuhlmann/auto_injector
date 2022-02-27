# frozen_string_literal: true

require "spec_helper"

RSpec.describe AutoInjector do
  subject(:injector) { described_class[Test::Container] }

  before do
    stub_const "Test::Container", {a: 1, b: 2, c: 3}
    stub_const "Test::Import", injector
  end

  describe ".[]" do
    let(:child) { Class.new.include Test::Import[:a, :b, :c] }

    it "answers injected dependencies" do
      expect(child.new.inspect).to include("@a=1, @b=2, @c=3")
    end
  end
end
