# frozen_string_literal: true

RSpec.describe Flourish::Border do
  describe "presets" do
    it "defines NORMAL with box-drawing characters" do
      b = Flourish::Border::NORMAL
      expect(b.top).to eq("─")
      expect(b.left).to eq("│")
      expect(b.top_left).to eq("┌")
      expect(b.top_right).to eq("┐")
      expect(b.bottom_left).to eq("└")
      expect(b.bottom_right).to eq("┘")
    end

    it "defines ROUNDED with rounded corners" do
      b = Flourish::Border::ROUNDED
      expect(b.top_left).to eq("╭")
      expect(b.top_right).to eq("╮")
      expect(b.bottom_left).to eq("╰")
      expect(b.bottom_right).to eq("╯")
    end

    it "defines THICK with heavy box-drawing" do
      b = Flourish::Border::THICK
      expect(b.top).to eq("━")
      expect(b.left).to eq("┃")
      expect(b.top_left).to eq("┏")
    end

    it "defines DOUBLE with double-line characters" do
      b = Flourish::Border::DOUBLE
      expect(b.top).to eq("═")
      expect(b.left).to eq("║")
      expect(b.top_left).to eq("╔")
    end

    it "defines BLOCK with full blocks" do
      b = Flourish::Border::BLOCK
      expect(b.top).to eq("█")
      expect(b.left).to eq("█")
      expect(b.top_left).to eq("█")
    end

    it "defines OUTER_HALF_BLOCK" do
      b = Flourish::Border::OUTER_HALF_BLOCK
      expect(b.top).to eq("▀")
      expect(b.bottom).to eq("▄")
      expect(b.left).to eq("▌")
      expect(b.right).to eq("▐")
    end

    it "defines INNER_HALF_BLOCK" do
      b = Flourish::Border::INNER_HALF_BLOCK
      expect(b.top).to eq("▄")
      expect(b.bottom).to eq("▀")
      expect(b.left).to eq("▐")
      expect(b.right).to eq("▌")
    end

    it "defines HIDDEN with spaces" do
      b = Flourish::Border::HIDDEN
      expect(b.top).to eq(" ")
      expect(b.left).to eq(" ")
      expect(b.top_left).to eq(" ")
    end

    it "defines ASCII with ASCII characters" do
      b = Flourish::Border::ASCII
      expect(b.top).to eq("-")
      expect(b.left).to eq("|")
      expect(b.top_left).to eq("+")
    end

    it "defines MARKDOWN" do
      b = Flourish::Border::MARKDOWN
      expect(b.top).to eq("-")
      expect(b.left).to eq("|")
      expect(b.top_left).to eq("+")
    end

    it "all presets are frozen" do
      [Flourish::Border::NORMAL, Flourish::Border::ROUNDED, Flourish::Border::THICK,
       Flourish::Border::DOUBLE, Flourish::Border::BLOCK, Flourish::Border::OUTER_HALF_BLOCK,
       Flourish::Border::INNER_HALF_BLOCK, Flourish::Border::HIDDEN,
       Flourish::Border::ASCII, Flourish::Border::MARKDOWN,].each do |b|
        expect(b).to be_frozen
      end
    end

    it "all presets have 13 fields" do
      b = Flourish::Border::NORMAL
      expect(b.to_h.keys.length).to eq(13)
    end

    it "all presets include middle fields" do
      b = Flourish::Border::NORMAL
      expect(b.middle_left).to eq("├")
      expect(b.middle_right).to eq("┤")
      expect(b.middle).to eq("┼")
      expect(b.middle_top).to eq("┬")
      expect(b.middle_bottom).to eq("┴")
    end
  end

  describe "BorderDef" do
    it "is a Data.define struct" do
      expect(Flourish::BorderDef.ancestors).to include(Data)
    end

    it "can be created with keyword args" do
      b = Flourish::BorderDef.new(
        top: "a", bottom: "b", left: "c", right: "d",
        top_left: "e", top_right: "f", bottom_left: "g", bottom_right: "h",
        middle_left: "i", middle_right: "j", middle: "k", middle_top: "l", middle_bottom: "m"
      )
      expect(b.top).to eq("a")
      expect(b.middle_bottom).to eq("m")
    end
  end
end
