# frozen_string_literal: true

RSpec.describe Flourish::Join do
  describe ".horizontal" do
    it "joins two single-line strings side by side" do
      result = described_class.horizontal(Flourish::TOP, "aaa", "bbb")
      expect(result).to eq("aaabbb")
    end

    it "equalizes heights (top-aligned)" do
      result = described_class.horizontal(Flourish::TOP, "a\nb", "x")
      lines = result.split("\n")
      expect(lines.length).to eq(2)
      expect(lines[0]).to eq("ax")
      expect(lines[1]).to start_with("b")
    end

    it "equalizes heights (bottom-aligned)" do
      result = described_class.horizontal(Flourish::BOTTOM, "a\nb", "x")
      lines = result.split("\n")
      expect(lines.length).to eq(2)
      expect(lines[0]).to start_with("a")
      expect(lines[1]).to include("x")
    end

    it "equalizes heights (center-aligned)" do
      result = described_class.horizontal(Flourish::CENTER, "a\nb\nc", "x")
      lines = result.split("\n")
      expect(lines.length).to eq(3)
      expect(lines[1]).to include("x")
    end

    it "pads shorter blocks to max width" do
      result = described_class.horizontal(Flourish::TOP, "a", "bb", "c")
      expect(result).to eq("abbc")
    end

    it "handles different widths across lines" do
      result = described_class.horizontal(Flourish::TOP, "ab\na", "x\nyz")
      lines = result.split("\n")
      expect(lines[0]).to eq("abx")
      # First block line 2 is "a" (width 1), padded to width 2
      expect(lines[1]).to eq("a yz")
    end

    it "handles empty input" do
      expect(described_class.horizontal(Flourish::TOP)).to eq("")
    end

    it "handles single input" do
      expect(described_class.horizontal(Flourish::TOP, "hi")).to eq("hi")
    end

    it "joins three blocks" do
      result = described_class.horizontal(Flourish::TOP, "A", "B", "C")
      expect(result).to eq("ABC")
    end

    it "preserves ANSI codes" do
      a = "\e[1mhi\e[0m"
      b = "yo"
      result = described_class.horizontal(Flourish::TOP, a, b)
      expect(result).to include("\e[1mhi\e[0m")
      expect(result).to include("yo")
    end

    it "handles multiline blocks with different widths" do
      a = "aaa\nbb"
      b = "x\nyy"
      result = described_class.horizontal(Flourish::TOP, a, b)
      lines = result.split("\n")
      # First block max width is 3
      expect(lines[0]).to eq("aaax")
      expect(lines[1]).to eq("bb yy")
    end
  end

  describe ".vertical" do
    it "stacks strings vertically" do
      result = described_class.vertical(Flourish::LEFT, "aaa", "bbb")
      expect(result).to eq("aaa\nbbb")
    end

    it "left-aligns narrower blocks" do
      result = described_class.vertical(Flourish::LEFT, "aaa", "b")
      lines = result.split("\n")
      expect(lines[0]).to eq("aaa")
      expect(lines[1]).to eq("b  ")
    end

    it "right-aligns narrower blocks" do
      result = described_class.vertical(Flourish::RIGHT, "aaa", "b")
      lines = result.split("\n")
      expect(lines[1]).to eq("  b")
    end

    it "center-aligns narrower blocks" do
      result = described_class.vertical(Flourish::CENTER, "aaaa", "bb")
      lines = result.split("\n")
      expect(lines[1]).to eq(" bb ")
    end

    it "handles empty input" do
      expect(described_class.vertical(Flourish::LEFT)).to eq("")
    end

    it "handles single input" do
      expect(described_class.vertical(Flourish::LEFT, "hi")).to eq("hi")
    end

    it "handles multiline blocks" do
      a = "aa\nbb"
      b = "cc\ndd"
      result = described_class.vertical(Flourish::LEFT, a, b)
      lines = result.split("\n")
      expect(lines).to eq(%w[aa bb cc dd])
    end

    it "preserves ANSI codes" do
      a = "\e[31mhi\e[0m"
      b = "yo"
      result = described_class.vertical(Flourish::LEFT, a, b)
      expect(result).to include("\e[31mhi\e[0m")
    end
  end
end
