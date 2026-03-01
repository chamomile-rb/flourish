# frozen_string_literal: true

RSpec.describe Flourish::Style do
  subject(:style) { described_class.new }

  describe "text attributes" do
    it "applies bold" do
      result = style.bold.render("hi")
      expect(result).to eq("\e[1mhi\e[0m")
    end

    it "applies italic" do
      result = style.italic.render("hi")
      expect(result).to eq("\e[3mhi\e[0m")
    end

    it "applies faint" do
      result = style.faint.render("hi")
      expect(result).to eq("\e[2mhi\e[0m")
    end

    it "applies underline" do
      result = style.underline.render("hi")
      expect(result).to eq("\e[4mhi\e[0m")
    end

    it "applies blink" do
      result = style.blink.render("hi")
      expect(result).to eq("\e[5mhi\e[0m")
    end

    it "applies reverse" do
      result = style.reverse.render("hi")
      expect(result).to eq("\e[7mhi\e[0m")
    end

    it "applies strikethrough" do
      result = style.strikethrough.render("hi")
      expect(result).to eq("\e[9mhi\e[0m")
    end

    it "combines multiple attributes" do
      result = style.bold.italic.render("hi")
      expect(result).to eq("\e[1;3mhi\e[0m")
    end

    it "returns self for chaining" do
      expect(style.bold).to be(style)
      expect(style.italic).to be(style)
    end
  end

  describe "colors" do
    it "applies ANSI foreground" do
      result = style.foreground("1").render("hi")
      expect(result).to eq("\e[31mhi\e[0m")
    end

    it "applies ANSI background" do
      result = style.background("4").render("hi")
      expect(result).to eq("\e[44mhi\e[0m")
    end

    it "applies 256-color foreground" do
      result = style.foreground("100").render("hi")
      expect(result).to eq("\e[38;5;100mhi\e[0m")
    end

    it "applies true color foreground" do
      result = style.foreground("#ff0000").render("hi")
      expect(result).to eq("\e[38;2;255;0;0mhi\e[0m")
    end

    it "applies true color background" do
      result = style.background("#00ff00").render("hi")
      expect(result).to eq("\e[48;2;0;255;0mhi\e[0m")
    end

    it "combines foreground and background" do
      result = style.foreground("1").background("4").render("hi")
      expect(result).to eq("\e[31;44mhi\e[0m")
    end

    it "combines attributes with colors" do
      result = style.bold.foreground("#ff0").render("hi")
      expect(result).to eq("\e[1;38;2;255;255;0mhi\e[0m")
    end

    it "handles NoColor foreground" do
      result = style.foreground("").render("hi")
      expect(result).to eq("hi")
    end
  end

  describe "getters" do
    it "reports bold?" do
      expect(style.bold?).to be false
      style.bold
      expect(style.bold?).to be true
    end

    it "reports italic?" do
      style.italic
      expect(style.italic?).to be true
    end

    it "reports foreground_color" do
      style.foreground("#ff0000")
      expect(style.foreground_color).to be_a(Flourish::Color::TrueColor)
    end

    it "reports background_color" do
      style.background("1")
      expect(style.background_color).to be_a(Flourish::Color::ANSIColor)
    end
  end

  describe "#render" do
    it "joins multiple args with space" do
      result = style.render("hello", "world")
      expect(result).to eq("hello world")
    end

    it "handles multiline text per line" do
      result = style.bold.render("a\nb")
      expect(result).to eq("\e[1ma\e[0m\n\e[1mb\e[0m")
    end

    it "preserves trailing newlines in split" do
      result = style.render("a\n")
      lines = result.split("\n", -1)
      expect(lines.length).to eq(2)
    end

    it "applies transform" do
      result = style.transform(&:upcase).render("hello")
      expect(result).to eq("HELLO")
    end

    it "converts tabs with default width" do
      result = style.render("\t")
      expect(result).to eq("    ")
    end

    it "converts tabs with custom width" do
      result = style.tab_width(2).render("\t")
      expect(result).to eq("  ")
    end

    it "returns empty string for empty input" do
      result = style.render("")
      expect(result).to eq("")
    end
  end

  describe "dimensions" do
    it "pads to width" do
      result = style.width(10).render("hi")
      expect(Flourish.width(result)).to eq(10)
    end

    it "wraps long text to width" do
      result = style.width(5).render("hello world")
      lines = result.split("\n")
      lines.each do |line|
        expect(Flourish.width(line)).to be <= 5
      end
    end

    it "enforces height by padding" do
      result = style.height(3).render("hi")
      expect(result.split("\n", -1).length).to eq(3)
    end

    it "enforces height by truncating" do
      result = style.height(1).render("a\nb\nc")
      expect(result.split("\n", -1).length).to eq(1)
    end

    it "enforces max_width" do
      result = style.max_width(3).render("hello")
      expect(Flourish.width(result)).to be <= 3
    end

    it "enforces max_height" do
      result = style.max_height(2).render("a\nb\nc\nd")
      expect(result.split("\n", -1).length).to be <= 2
    end
  end

  describe "padding" do
    it "applies uniform padding" do
      result = style.width(10).padding(1).render("hi")
      lines = result.split("\n", -1)
      # top padding + content + bottom padding
      expect(lines.length).to eq(3)
    end

    it "applies padding with 2 args (vertical, horizontal)" do
      style.padding(0, 2)
      expect(style.send(:effective_padding_top)).to eq(0)
      expect(style.send(:effective_padding_right)).to eq(2)
      expect(style.send(:effective_padding_bottom)).to eq(0)
      expect(style.send(:effective_padding_left)).to eq(2)
    end

    it "applies padding with 4 args" do
      style.padding(1, 2, 3, 4)
      expect(style.send(:effective_padding_top)).to eq(1)
      expect(style.send(:effective_padding_right)).to eq(2)
      expect(style.send(:effective_padding_bottom)).to eq(3)
      expect(style.send(:effective_padding_left)).to eq(4)
    end

    it "applies individual padding" do
      style.padding_left(3)
      expect(style.send(:effective_padding_left)).to eq(3)
    end

    it "adds left/right padding to content" do
      result = style.padding_left(2).padding_right(2).render("hi")
      expect(result).to eq("  hi  ")
    end

    it "adds top/bottom padding lines" do
      result = style.width(4).padding_top(1).padding_bottom(1).render("hi")
      lines = result.split("\n", -1)
      expect(lines.length).to eq(3)
    end
  end

  describe "margin" do
    it "applies uniform margin" do
      style.margin(1)
      expect(style.send(:effective_margin_top)).to eq(1)
      expect(style.send(:effective_margin_right)).to eq(1)
      expect(style.send(:effective_margin_bottom)).to eq(1)
      expect(style.send(:effective_margin_left)).to eq(1)
    end

    it "applies margin with 2 args" do
      style.margin(1, 2)
      expect(style.send(:effective_margin_top)).to eq(1)
      expect(style.send(:effective_margin_right)).to eq(2)
    end

    it "applies margin with 4 args" do
      style.margin(1, 2, 3, 4)
      expect(style.send(:effective_margin_top)).to eq(1)
      expect(style.send(:effective_margin_right)).to eq(2)
      expect(style.send(:effective_margin_bottom)).to eq(3)
      expect(style.send(:effective_margin_left)).to eq(4)
    end

    it "adds left/right margin" do
      result = style.margin_left(2).margin_right(2).render("hi")
      expect(result).to eq("  hi  ")
    end

    it "adds top/bottom margin lines" do
      result = style.margin_top(1).margin_bottom(1).render("hi")
      lines = result.split("\n", -1)
      expect(lines.length).to eq(3)
      expect(lines[0]).to eq("")
      expect(lines[2]).to eq("")
    end
  end

  describe "border" do
    it "adds all-sides border" do
      result = style.border(Flourish::Border::ASCII).render("hi")
      lines = result.split("\n")
      expect(lines[0]).to include("+")
      expect(lines[0]).to include("-")
      expect(lines[1]).to start_with("|")
      expect(lines[1]).to end_with("|")
      expect(lines[2]).to include("+")
    end

    it "adds border with specific sides" do
      result = style.border(Flourish::Border::ASCII, true, false, true, false).render("hi")
      lines = result.split("\n")
      # top and bottom but no left/right
      expect(lines[0]).to include("-")
      expect(lines[1]).not_to start_with("|")
    end

    it "sets border_style separately" do
      style.border_style(Flourish::Border::ROUNDED)
      style.border_top
      style.border_bottom
      style.border_left
      style.border_right
      result = style.render("hi")
      lines = result.split("\n")
      expect(lines[0]).to include("╭")
    end

    it "applies border foreground color" do
      style.border(Flourish::Border::ASCII).border_foreground("1")
      result = style.render("hi")
      expect(result).to include("\e[31m")
    end

    it "applies per-side border foreground" do
      style.border(Flourish::Border::ASCII)
      style.border_top_foreground("1")
      result = style.render("hi")
      lines = result.split("\n")
      expect(lines[0]).to include("\e[31m")
    end

    it "border is included in width calculation" do
      result = style.width(10).border(Flourish::Border::ASCII).render("hi")
      lines = result.split("\n")
      # Total width should be 10
      expect(Flourish.width(lines[1])).to eq(10)
    end

    it "adds ROUNDED border" do
      result = style.border(Flourish::Border::ROUNDED).render("hi")
      lines = result.split("\n")
      expect(lines[0]).to start_with("╭")
      expect(lines[0]).to end_with("╮")
    end

    it "adds only top border" do
      style.border_style(Flourish::Border::ASCII)
      style.border_top
      result = style.render("hi")
      lines = result.split("\n")
      expect(lines.length).to eq(2) # top border + content
    end
  end

  describe "alignment" do
    it "aligns horizontal center" do
      result = style.width(10).align_horizontal(0.5).render("hi")
      stripped = Flourish::ANSI.strip(result)
      expect(stripped).to include("    hi")
    end

    it "aligns horizontal right" do
      result = style.width(10).align_horizontal(1.0).render("hi")
      stripped = Flourish::ANSI.strip(result)
      expect(stripped).to include("        hi")
    end

    it "aligns horizontal left (default)" do
      result = style.width(10).render("hi")
      stripped = Flourish::ANSI.strip(result)
      expect(stripped).to start_with("hi")
    end

    it "aligns vertical center" do
      result = style.height(5).align_vertical(0.5).render("hi")
      lines = result.split("\n", -1)
      expect(lines.length).to eq(5)
      expect(lines[2]).to eq("hi")
    end

    it "sets align with 2 args" do
      style.align(0.5, 0.5)
      expect(style.send(:effective_align_horizontal)).to eq(0.5)
      expect(style.send(:effective_align_vertical)).to eq(0.5)
    end
  end

  describe "inheritance" do
    it "inherits unset props from parent" do
      parent = described_class.new.bold.foreground("1")
      child = described_class.new.italic
      child.inherit(parent)
      expect(child.bold?).to be true
      expect(child.italic?).to be true
    end

    it "does not override set props" do
      parent = described_class.new.foreground("1")
      child = described_class.new.foreground("2")
      child.inherit(parent)
      expect(child.foreground_color.code).to eq(2)
    end
  end

  describe "#unset" do
    it "removes a prop" do
      style.bold
      expect(style.bold?).to be true
      style.unset(Flourish::Style::BOLD)
      expect(style.bold?).to be false
    end

    it "removes multiple props" do
      style.bold.italic
      style.unset(Flourish::Style::BOLD, Flourish::Style::ITALIC)
      expect(style.bold?).to be false
      expect(style.italic?).to be false
    end
  end

  describe "#set?" do
    it "returns false for unset prop" do
      expect(style.set?(Flourish::Style::BOLD)).to be false
    end

    it "returns true for set prop" do
      style.bold
      expect(style.set?(Flourish::Style::BOLD)).to be true
    end
  end

  describe "#copy" do
    it "creates an independent copy" do
      style.bold.foreground("1")
      copy = style.copy
      copy.italic
      expect(style.italic?).to be false
      expect(copy.bold?).to be true
    end
  end

  describe "whitespace options" do
    it "supports underline_spaces" do
      style.underline_spaces
      expect(style.underline_spaces?).to be true
    end

    it "supports strikethrough_spaces" do
      style.strikethrough_spaces
      expect(style.strikethrough_spaces?).to be true
    end

    it "supports color_whitespace" do
      style.color_whitespace.background("1")
      expect(style.color_whitespace?).to be true
    end

    it "applies bg color to padding whitespace when color_whitespace is set" do
      result = style.color_whitespace.background("1").padding_left(2).render("hi")
      expect(result).to include("\e[41m")
    end
  end

  describe "complex combinations" do
    it "renders with padding + border + margin" do
      result = style
               .width(20)
               .padding(1, 2)
               .border(Flourish::Border::ASCII)
               .margin(1, 2)
               .render("hello")

      lines = result.split("\n", -1)
      # margin(1) + border(1) + padding(1) + content(1) + padding(1) + border(1) + margin(1)
      expect(lines.length).to eq(7)
    end

    it "renders with all text attributes and colors" do
      result = style
               .bold
               .italic
               .underline
               .foreground("#ff0000")
               .background("#0000ff")
               .render("test")

      expect(result).to include("\e[")
      expect(result).to include("test")
      expect(result).to end_with("\e[0m")
    end
  end

  describe "border_background" do
    it "applies background to all border sides" do
      style.border(Flourish::Border::ASCII).border_background("4")
      result = style.render("hi")
      expect(result).to include("\e[44m")
    end

    it "applies per-side background" do
      style.border(Flourish::Border::ASCII)
      style.border_top_background("1")
      result = style.render("hi")
      lines = result.split("\n")
      expect(lines[0]).to include("\e[41m")
    end
  end

  describe "border foreground CSS shorthand" do
    it "applies 1 color to all sides" do
      style.border(Flourish::Border::ASCII).border_foreground("1")
      result = style.render("hi")
      lines = result.split("\n")
      lines.each { |l| expect(l).to include("\e[31m") }
    end

    it "applies 2 colors (vertical, horizontal)" do
      style.border(Flourish::Border::ASCII).border_foreground("1", "2")
      result = style.render("hi")
      # Top uses color "1", sides use color "2"
      lines = result.split("\n")
      expect(lines[0]).to include("\e[31m") # top
      expect(lines[1]).to include("\e[32m") # left/right
    end
  end

  describe "padding CSS shorthand" do
    it "applies 3 args (top, horizontal, bottom)" do
      style.padding(1, 2, 3)
      expect(style.send(:effective_padding_top)).to eq(1)
      expect(style.send(:effective_padding_right)).to eq(2)
      expect(style.send(:effective_padding_bottom)).to eq(3)
      expect(style.send(:effective_padding_left)).to eq(2)
    end
  end

  describe "margin CSS shorthand" do
    it "applies 3 args (top, horizontal, bottom)" do
      style.margin(1, 2, 3)
      expect(style.send(:effective_margin_top)).to eq(1)
      expect(style.send(:effective_margin_right)).to eq(2)
      expect(style.send(:effective_margin_bottom)).to eq(3)
      expect(style.send(:effective_margin_left)).to eq(2)
    end
  end

  describe "max_width interaction with content" do
    it "truncates wide styled content" do
      result = style.bold.max_width(5).render("hello world")
      expect(Flourish.width(result)).to be <= 5
    end
  end

  describe "max_height interaction with content" do
    it "truncates tall content" do
      result = style.max_height(2).render("a\nb\nc\nd\ne")
      lines = result.split("\n", -1)
      expect(lines.length).to be <= 2
    end
  end

  describe "width with border" do
    it "total width includes border" do
      result = style.width(10).border(Flourish::Border::ASCII).render("hi")
      lines = result.split("\n")
      expect(Flourish.width(lines[0])).to eq(10)
      expect(Flourish.width(lines[1])).to eq(10)
    end
  end

  describe "width with padding and border" do
    it "total width includes padding and border" do
      result = style.width(20).padding(0, 2).border(Flourish::Border::ASCII).render("hi")
      lines = result.split("\n")
      expect(Flourish.width(lines[1])).to eq(20)
    end
  end

  describe "inline mode" do
    it "can be set and queried" do
      style.inline
      expect(style.inline?).to be true
    end
  end

  describe "multiple renders with same style" do
    it "produces consistent results" do
      style.bold.foreground("1").width(10)
      r1 = style.render("test")
      r2 = style.render("test")
      expect(r1).to eq(r2)
    end
  end

  describe "empty content with dimensions" do
    it "renders empty content with width" do
      result = style.width(10).render("")
      expect(Flourish.width(result)).to eq(10)
    end

    it "renders empty content with height" do
      result = style.height(3).render("")
      lines = result.split("\n", -1)
      expect(lines.length).to eq(3)
    end
  end

  describe "border only on some sides" do
    it "renders with only left border" do
      style.border_style(Flourish::Border::ASCII).border_left
      result = style.render("hi")
      lines = result.split("\n")
      expect(lines[0]).to start_with("|")
      expect(lines.length).to eq(1)
    end

    it "renders with top and bottom only" do
      style.border_style(Flourish::Border::ASCII)
      style.border_top
      style.border_bottom
      result = style.render("hi")
      lines = result.split("\n")
      expect(lines.length).to eq(3)
      expect(lines[0]).to include("-")
      expect(lines[1]).to eq("hi")
      expect(lines[2]).to include("-")
    end
  end

  describe "all 10 border presets render" do
    [
      Flourish::Border::NORMAL, Flourish::Border::ROUNDED, Flourish::Border::THICK,
      Flourish::Border::DOUBLE, Flourish::Border::BLOCK, Flourish::Border::OUTER_HALF_BLOCK,
      Flourish::Border::INNER_HALF_BLOCK, Flourish::Border::HIDDEN,
      Flourish::Border::ASCII, Flourish::Border::MARKDOWN,
    ].each do |preset|
      it "renders with #{preset.top_left} border" do
        result = described_class.new.border(preset).render("test")
        lines = result.split("\n")
        expect(lines.length).to eq(3) # top + content + bottom
      end
    end
  end

  describe "color_whitespace with padding" do
    it "does not style whitespace when color_whitespace is false" do
      result = style.background("1").padding_left(2).render("hi")
      # Background is applied to content via SGR, not to padding spaces
      expect(result).to start_with("  \e[41m")
    end

    it "styles whitespace when color_whitespace is true" do
      result = style.color_whitespace.background("1").padding_left(2).render("hi")
      expect(result).to start_with("\e[41m  \e[0m")
    end
  end

  describe "height with vertical alignment" do
    it "bottom-aligns content in height" do
      result = style.height(5).align_vertical(1.0).render("hi")
      lines = result.split("\n", -1)
      expect(lines.length).to eq(5)
      expect(lines[4]).to eq("hi")
      expect(lines[0]).to eq("")
    end

    it "center-aligns content in height" do
      result = style.height(5).align_vertical(0.5).render("hi")
      lines = result.split("\n", -1)
      expect(lines.length).to eq(5)
      expect(lines[2]).to eq("hi")
    end
  end

  describe "multiline content with width" do
    it "wraps and aligns multiline content" do
      result = style.width(10).align_horizontal(0.5).render("a\nb\nc")
      lines = result.split("\n")
      lines.each do |line|
        expect(Flourish.width(line)).to eq(10)
      end
    end
  end

  describe "chaining returns self" do
    it "returns self for all setters" do
      s = described_class.new
      expect(s.bold).to be(s)
      expect(s.italic).to be(s)
      expect(s.faint).to be(s)
      expect(s.blink).to be(s)
      expect(s.strikethrough).to be(s)
      expect(s.underline).to be(s)
      expect(s.reverse).to be(s)
      expect(s.foreground("1")).to be(s)
      expect(s.background("1")).to be(s)
      expect(s.width(10)).to be(s)
      expect(s.height(5)).to be(s)
      expect(s.max_width(20)).to be(s)
      expect(s.max_height(10)).to be(s)
      expect(s.padding(1)).to be(s)
      expect(s.margin(1)).to be(s)
      expect(s.border(Flourish::Border::ASCII)).to be(s)
      expect(s.align(0.5)).to be(s)
      expect(s.tab_width(2)).to be(s)
      expect(s.inline).to be(s)
      expect(s.underline_spaces).to be(s)
      expect(s.strikethrough_spaces).to be(s)
      expect(s.color_whitespace).to be(s)
    end
  end

  describe "getters return defaults" do
    it "returns default values for unset properties" do
      s = described_class.new
      expect(s.bold?).to be false
      expect(s.italic?).to be false
      expect(s.faint?).to be false
      expect(s.blink?).to be false
      expect(s.strikethrough?).to be false
      expect(s.underline?).to be false
      expect(s.reverse?).to be false
      expect(s.foreground_color).to be_nil
      expect(s.background_color).to be_nil
      expect(s.send(:effective_tab_width)).to eq(4)
      expect(s.inline?).to be false
      expect(s.send(:effective_width)).to eq(0)
      expect(s.send(:effective_height)).to eq(0)
      expect(s.send(:effective_max_width)).to eq(0)
      expect(s.send(:effective_max_height)).to eq(0)
      expect(s.send(:effective_padding_top)).to eq(0)
      expect(s.send(:effective_padding_right)).to eq(0)
      expect(s.send(:effective_padding_bottom)).to eq(0)
      expect(s.send(:effective_padding_left)).to eq(0)
      expect(s.send(:effective_margin_top)).to eq(0)
      expect(s.send(:effective_margin_right)).to eq(0)
      expect(s.send(:effective_margin_bottom)).to eq(0)
      expect(s.send(:effective_margin_left)).to eq(0)
      expect(s.send(:effective_border_style)).to be_nil
      expect(s.border_top?).to be false
      expect(s.border_right?).to be false
      expect(s.border_bottom?).to be false
      expect(s.border_left?).to be false
      expect(s.underline_spaces?).to be false
      expect(s.strikethrough_spaces?).to be false
      expect(s.color_whitespace?).to be false
    end
  end
end
