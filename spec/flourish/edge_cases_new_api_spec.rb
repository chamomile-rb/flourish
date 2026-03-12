# frozen_string_literal: true

require "spec_helper"

RSpec.describe "new API edge cases" do
  describe "Flourish.place" do
    it "coerces non-string content to string" do
      result = Flourish.place(42, width: 10, height: 1)
      expect(result).to include("42")
    end

    it "handles nil content" do
      result = Flourish.place(nil, width: 10, height: 1)
      expect(result).to be_a(String)
    end

    it "old 5-arg form with symbols works" do
      result = Flourish.place(20, 3, :center, :center, "hi")
      expect(result).to include("hi")
    end

    it "old 5-arg form with floats works" do
      result = Flourish.place(20, 3, 0.5, 0.5, "hi")
      expect(result).to include("hi")
    end

    it "new keyword form works" do
      result = Flourish.place("hi", width: 20, height: 3, align: :center, valign: :center)
      expect(result).to include("hi")
    end

    it "defaults to 80x24 with no size args" do
      result = Flourish.place("hello")
      expect(result).to be_a(String)
      expect(result).to include("hello")
    end
  end

  describe "Flourish.horizontal" do
    it "handles empty array" do
      expect(Flourish.horizontal([], align: :top)).to eq("")
    end

    it "handles single element" do
      expect(Flourish.horizontal(["hello"], align: :top)).to eq("hello")
    end

    it "handles single string (not array)" do
      expect(Flourish.horizontal("hello", align: :top)).to eq("hello")
    end

    it "block returning nil returns empty string" do
      expect(Flourish.horizontal(align: :top) { nil }).to eq("")
    end
  end

  describe "Flourish.vertical" do
    it "handles empty array" do
      expect(Flourish.vertical([], align: :left)).to eq("")
    end

    it "handles single element" do
      expect(Flourish.vertical(["hello"], align: :left)).to eq("hello")
    end
  end

  describe "resolve_position" do
    it "handles all valid symbols" do
      expect(Flourish.resolve_position(:top)).to eq(0.0)
      expect(Flourish.resolve_position(:left)).to eq(0.0)
      expect(Flourish.resolve_position(:center)).to eq(0.5)
      expect(Flourish.resolve_position(:bottom)).to eq(1.0)
      expect(Flourish.resolve_position(:right)).to eq(1.0)
    end

    it "passes through floats" do
      expect(Flourish.resolve_position(0.25)).to eq(0.25)
    end

    it "raises for unknown symbol" do
      expect { Flourish.resolve_position(:invalid) }.to raise_error(ArgumentError)
    end
  end
end
