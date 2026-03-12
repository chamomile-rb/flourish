# frozen_string_literal: true

require "spec_helper"

RSpec.describe "backward compatibility" do
  describe "float position constants" do
    it "Flourish::TOP still works" do
      expect(Flourish::TOP).to eq(0.0)
    end

    it "Flourish::CENTER still works" do
      expect(Flourish::CENTER).to eq(0.5)
    end

    it "Flourish::BOTTOM still works" do
      expect(Flourish::BOTTOM).to eq(1.0)
    end

    it "Flourish::LEFT still works" do
      expect(Flourish::LEFT).to eq(0.0)
    end

    it "Flourish::RIGHT still works" do
      expect(Flourish::RIGHT).to eq(1.0)
    end
  end

  describe "old join methods" do
    it "join_horizontal(Flourish::TOP, ...) still works" do
      result = Flourish.join_horizontal(Flourish::TOP, "hello", "world")
      expect(result).to include("hello")
      expect(result).to include("world")
    end

    it "join_vertical(Flourish::LEFT, ...) still works" do
      result = Flourish.join_vertical(Flourish::LEFT, "hello", "world")
      expect(result).to include("hello")
      expect(result).to include("world")
    end
  end

  describe "old align with floats" do
    it "align_horizontal(0.5) still works" do
      style = Flourish::Style.new.width(20).align_horizontal(0.5)
      result = style.render("hi")
      expect(result).to include("hi")
    end

    it "align_vertical(0.5) still works" do
      style = Flourish::Style.new.height(5).align_vertical(0.5)
      result = style.render("hi")
      expect(result).to include("hi")
    end
  end

  describe "old place 5-arg form" do
    it "place(80, 24, Flourish::CENTER, Flourish::CENTER, content) still works" do
      result = Flourish.place(20, 3, Flourish::CENTER, Flourish::CENTER, "hi")
      expect(result).to include("hi")
    end
  end
end
