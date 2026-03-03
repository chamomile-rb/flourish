# frozen_string_literal: true

RSpec.describe "Edge cases" do
  describe "ANSI.strip edge cases" do
    it "handles nested escape sequences" do
      expect(Flourish::ANSI.strip("\e[1m\e[31mhi\e[0m")).to eq("hi")
    end

    it "handles partial escape at end of string" do
      expect(Flourish::ANSI.strip("hi\e")).to eq("hi\e")
    end

    it "handles CSI with many params" do
      expect(Flourish::ANSI.strip("\e[1;2;3;4;5mhi\e[0m")).to eq("hi")
    end

    it "handles cursor movement sequences" do
      expect(Flourish::ANSI.strip("\e[10;20Hhi")).to eq("hi")
    end

    it "handles erase sequences" do
      expect(Flourish::ANSI.strip("\e[2Jhi\e[K")).to eq("hi")
    end
  end

  describe "ANSI.printable_width edge cases" do
    it "handles tabs as control characters (width 0)" do
      expect(Flourish::ANSI.printable_width("\t")).to eq(0)
    end

    it "handles mixed widths" do
      # ASCII(1) + CJK(2) + ASCII(1)
      expect(Flourish::ANSI.printable_width("a你b")).to eq(4)
    end

    it "handles long strings" do
      str = "a" * 1000
      expect(Flourish::ANSI.printable_width(str)).to eq(1000)
    end

    it "handles only ANSI codes" do
      expect(Flourish::ANSI.printable_width("\e[1m\e[0m")).to eq(0)
    end
  end

  describe "Color.parse edge cases" do
    it "parses #000 as black" do
      color = Flourish::Color.parse("#000")
      expect(color.r).to eq(0)
      expect(color.g).to eq(0)
      expect(color.b).to eq(0)
    end

    it "parses #fff as white" do
      color = Flourish::Color.parse("#fff")
      expect(color.r).to eq(255)
      expect(color.g).to eq(255)
      expect(color.b).to eq(255)
    end

    it "handles edge ANSI codes" do
      expect(Flourish::Color.parse("0")).to be_a(Flourish::Color::ANSIColor)
      expect(Flourish::Color.parse("15")).to be_a(Flourish::Color::ANSIColor)
      expect(Flourish::Color.parse("16")).to be_a(Flourish::Color::ANSI256Color)
      expect(Flourish::Color.parse("255")).to be_a(Flourish::Color::ANSI256Color)
    end
  end

  describe "ColorProfile.downsample edge cases" do
    it "handles dark gray" do
      color = Flourish::Color::TrueColor.new(30, 30, 30)
      result = Flourish::ColorProfile.downsample(color, Flourish::ColorProfile::ANSI256)
      expect(result).to be_a(Flourish::Color::ANSI256Color)
    end

    it "handles light gray" do
      color = Flourish::Color::TrueColor.new(220, 220, 220)
      result = Flourish::ColorProfile.downsample(color, Flourish::ColorProfile::ANSI256)
      expect(result).to be_a(Flourish::Color::ANSI256Color)
    end

    it "handles mid-range colors" do
      color = Flourish::Color::TrueColor.new(100, 150, 200)
      result = Flourish::ColorProfile.downsample(color, Flourish::ColorProfile::ANSI256)
      expect(result).to be_a(Flourish::Color::ANSI256Color)
      expect(result.code).to be_between(16, 255)
    end

    it "handles NoColor input" do
      color = Flourish::Color::NoColor.new
      result = Flourish::ColorProfile.downsample(color, Flourish::ColorProfile::ANSI)
      expect(result).to be_a(Flourish::Color::NoColor)
    end

    it "downsample pure green to 256" do
      color = Flourish::Color::TrueColor.new(0, 255, 0)
      result = Flourish::ColorProfile.downsample(color, Flourish::ColorProfile::ANSI256)
      expect(result).to be_a(Flourish::Color::ANSI256Color)
    end

    it "downsample pure blue to 256" do
      color = Flourish::Color::TrueColor.new(0, 0, 255)
      result = Flourish::ColorProfile.downsample(color, Flourish::ColorProfile::ANSI256)
      expect(result).to be_a(Flourish::Color::ANSI256Color)
    end
  end

  describe "Style render with no properties" do
    it "returns text unchanged" do
      expect(Flourish::Style.new.render("hello")).to eq("hello")
    end
  end

  describe "Style with only colors (no attributes)" do
    it "renders foreground only" do
      result = Flourish::Style.new.foreground("2").render("hi")
      expect(result).to eq("\e[32mhi\e[0m")
    end

    it "renders background only" do
      result = Flourish::Style.new.background("3").render("hi")
      expect(result).to eq("\e[43mhi\e[0m")
    end
  end

  describe "Word wrap edge cases" do
    it "wraps exactly at width boundary" do
      result = Flourish::Wrap.word_wrap("abcde fghij", 5)
      lines = result.split("\n")
      expect(lines[0]).to eq("abcde")
    end

    it "handles single character width" do
      result = Flourish::Wrap.word_wrap("ab", 1)
      lines = result.split("\n")
      expect(lines.length).to eq(2)
    end

    it "handles string of spaces" do
      result = Flourish::Wrap.word_wrap("     ", 3)
      lines = result.split("\n")
      lines.each { |l| expect(Flourish::ANSI.printable_width(l)).to be <= 3 }
    end

    it "handles very long word" do
      result = Flourish::Wrap.word_wrap("supercalifragilistic", 5)
      lines = result.split("\n")
      lines.each { |l| expect(Flourish::ANSI.printable_width(l)).to be <= 5 }
    end
  end

  describe "Border with width constraint" do
    it "content fills to width minus borders" do
      style = Flourish::Style.new.width(20).border(Flourish::Border::ASCII)
      result = style.render("hi")
      lines = result.split("\n")
      lines.each do |line|
        expect(Flourish.width(line)).to eq(20)
      end
    end
  end

  describe "Margin with border and padding" do
    it "margin is outermost layer" do
      result = Flourish::Style.new
                              .padding(0, 1)
                              .border(Flourish::Border::ASCII)
                              .margin_left(3)
                              .render("x")

      lines = result.split("\n")
      lines.each do |line|
        expect(line).to start_with("   ") # 3 spaces of margin
      end
    end
  end

  describe "Align with ANSI-styled content" do
    it "aligns based on printable width, not byte count" do
      lines = ["\e[1mhi\e[0m"]
      result = Flourish::Align.horizontal(lines, 10, 1.0)
      # "hi" is 2 chars, 8 spaces on left
      expect(result[0]).to start_with("        ")
    end
  end

  describe "Join with empty strings" do
    it "joins empty strings horizontally" do
      result = Flourish::Join.horizontal(Flourish::TOP, "", "")
      expect(result).to eq("")
    end

    it "joins empty strings vertically" do
      result = Flourish::Join.vertical(Flourish::LEFT, "", "")
      expect(result).to eq("")
    end
  end

  describe "Place with content larger than box" do
    it "does not crash when content is wider than box" do
      result = Flourish::Place.place(5, 3, Flourish::CENTER, Flourish::CENTER, "hello world")
      expect(result).to include("hello world")
    end

    it "does not crash when content is taller than box" do
      result = Flourish::Place.place(10, 1, Flourish::CENTER, Flourish::CENTER, "a\nb\nc")
      expect(result).to include("a")
    end
  end

  describe "Style.copy preserves all properties" do
    it "copies text attributes" do
      original = Flourish::Style.new.bold.italic.underline
      copy = original.copy
      expect(copy.bold?).to be true
      expect(copy.italic?).to be true
      expect(copy.underline?).to be true
    end

    it "copies colors" do
      original = Flourish::Style.new.foreground("#ff0").background("1")
      copy = original.copy
      expect(copy.foreground_color).to be_a(Flourish::Color::TrueColor)
      expect(copy.background_color).to be_a(Flourish::Color::ANSIColor)
    end

    it "copies dimensions" do
      original = Flourish::Style.new.width(20).height(10).padding(1, 2)
      copy = original.copy
      expect(copy.send(:effective_width)).to eq(20)
      expect(copy.send(:effective_height)).to eq(10)
      expect(copy.send(:effective_padding_top)).to eq(1)
      expect(copy.send(:effective_padding_right)).to eq(2)
    end
  end

  describe "Style inherit with complex properties" do
    it "inherits border style" do
      parent = Flourish::Style.new.border(Flourish::Border::ROUNDED)
      child = Flourish::Style.new.bold
      result = child.inherit(parent)
      expect(result.send(:effective_border_style)).to eq(Flourish::Border::ROUNDED)
      expect(result.border_top?).to be true
    end

    it "inherits padding" do
      parent = Flourish::Style.new.padding(1, 2, 3, 4)
      child = Flourish::Style.new
      result = child.inherit(parent)
      expect(result.send(:effective_padding_top)).to eq(1)
      expect(result.send(:effective_padding_right)).to eq(2)
      expect(result.send(:effective_padding_bottom)).to eq(3)
      expect(result.send(:effective_padding_left)).to eq(4)
    end

    it "child overrides inherited properties" do
      parent = Flourish::Style.new.padding(1)
      child = Flourish::Style.new.padding(2)
      result = child.inherit(parent)
      expect(result.send(:effective_padding_top)).to eq(2)
    end
  end

  describe "Style unset restores defaults" do
    it "unset foreground reverts to no color" do
      style = Flourish::Style.new.foreground("1")
      s2 = style.unset(Flourish::Style::FOREGROUND)
      expect(s2.foreground_color).to be_nil
      result = s2.render("hi")
      expect(result).to eq("hi")
    end

    it "unset width reverts to no width" do
      style = Flourish::Style.new.width(10)
      s2 = style.unset(Flourish::Style::WIDTH)
      expect(s2.send(:effective_width)).to eq(0)
    end
  end

  describe "Multiple border foreground colors" do
    it "applies 4 different colors to each side" do
      style = Flourish::Style.new
                             .border(Flourish::Border::ASCII)
                             .border_foreground("1", "2", "3", "4")
      result = style.render("x")
      lines = result.split("\n")
      expect(lines[0]).to include("\e[31m") # top = color 1
      expect(lines[2]).to include("\e[33m") # bottom = color 3
    end
  end

  describe "Style transform with ANSI" do
    it "transform runs before ANSI application" do
      result = Flourish::Style.new.bold.transform(&:upcase).render("hello")
      expect(Flourish::ANSI.strip(result)).to eq("HELLO")
    end
  end

  describe "ANSI.height edge cases" do
    it "handles multiple consecutive newlines" do
      expect(Flourish::ANSI.height("\n\n\n")).to eq(4)
    end

    it "handles single newline" do
      expect(Flourish::ANSI.height("\n")).to eq(2)
    end
  end

  describe "ANSI.size edge cases" do
    it "handles lines of varying width" do
      w, h = Flourish::ANSI.size("a\nbb\nccc")
      expect(w).to eq(3)
      expect(h).to eq(3)
    end

    it "handles styled multiline" do
      w, h = Flourish::ANSI.size("\e[1mhello\e[0m\n\e[2mhi\e[0m")
      expect(w).to eq(5)
      expect(h).to eq(2)
    end
  end

  describe "Style render multiline preserves structure" do
    it "applies SGR to each line independently" do
      result = Flourish::Style.new.bold.render("a\nb\nc")
      lines = result.split("\n")
      expect(lines.length).to eq(3)
      lines.each do |line|
        expect(line).to start_with("\e[1m")
        expect(line).to end_with("\e[0m")
      end
    end
  end

  describe "Color named constants are correct type" do
    it "all named colors are ANSIColor" do
      [Flourish::Color::BLACK, Flourish::Color::RED, Flourish::Color::GREEN,
       Flourish::Color::YELLOW, Flourish::Color::BLUE, Flourish::Color::MAGENTA,
       Flourish::Color::CYAN, Flourish::Color::WHITE,
       Flourish::Color::BRIGHT_BLACK, Flourish::Color::BRIGHT_RED,
       Flourish::Color::BRIGHT_GREEN, Flourish::Color::BRIGHT_YELLOW,
       Flourish::Color::BRIGHT_BLUE, Flourish::Color::BRIGHT_MAGENTA,
       Flourish::Color::BRIGHT_CYAN, Flourish::Color::BRIGHT_WHITE,].each do |color|
        expect(color).to be_a(Flourish::Color::ANSIColor)
        expect(color.no_color?).to be false
      end
    end
  end

  describe "Border presets have correct structure" do
    it "all presets respond to all fields" do
      presets = [
        Flourish::Border::NORMAL, Flourish::Border::ROUNDED,
        Flourish::Border::THICK, Flourish::Border::DOUBLE,
        Flourish::Border::BLOCK, Flourish::Border::OUTER_HALF_BLOCK,
        Flourish::Border::INNER_HALF_BLOCK, Flourish::Border::HIDDEN,
        Flourish::Border::ASCII, Flourish::Border::MARKDOWN,
      ]
      fields = %i[top bottom left right top_left top_right bottom_left bottom_right
                  middle_left middle_right middle middle_top middle_bottom]
      presets.each do |preset|
        fields.each do |field|
          expect(preset).to respond_to(field)
          expect(preset.send(field)).to be_a(String)
          expect(preset.send(field).length).to be >= 1
        end
      end
    end
  end

  describe "Join.horizontal preserves ANSI in multiline blocks" do
    it "preserves ANSI codes in joined output" do
      a = "\e[31mred\e[0m\n\e[31mline\e[0m"
      b = "plain\ntext"
      result = Flourish::Join.horizontal(Flourish::TOP, a, b)
      expect(result).to include("\e[31mred\e[0m")
      expect(result).to include("plain")
    end
  end

  describe "Join.vertical with different numbers of lines" do
    it "handles blocks with different line counts" do
      a = "one\ntwo\nthree"
      b = "single"
      result = Flourish::Join.vertical(Flourish::LEFT, a, b)
      lines = result.split("\n")
      expect(lines.length).to eq(4)
    end
  end

  describe "Place.place_horizontal with empty string" do
    it "pads empty content to width" do
      result = Flourish::Place.place_horizontal(10, Flourish::LEFT, "x")
      expect(Flourish.width(result)).to eq(10)
    end
  end

  describe "Style with tab_width 0" do
    it "does not convert tabs when tab_width is 0" do
      result = Flourish::Style.new.tab_width(0).render("\t")
      expect(result).to eq("\t")
    end
  end

  describe "Style border with width exactly matching border width" do
    it "handles width equal to border width (2)" do
      result = Flourish::Style.new.width(2).border(Flourish::Border::ASCII).render("")
      lines = result.split("\n")
      expect(Flourish.width(lines[0])).to eq(2)
    end
  end

  describe "Multiple text attributes" do
    it "renders all 7 attributes together" do
      result = Flourish::Style.new
                              .bold.italic.faint.blink.strikethrough.underline.reverse
                              .render("x")
      expect(result).to include("1;2;3;4;5;7;9")
    end
  end

  describe "Style boolean setters with false" do
    it "can disable bold" do
      style = Flourish::Style.new.bold(true)
      expect(style.bold?).to be true
      s2 = style.bold(false)
      expect(s2.bold?).to be false
    end

    it "can disable border sides" do
      style = Flourish::Style.new.border(Flourish::Border::ASCII)
      expect(style.border_top?).to be true
      s2 = style.border_top(false)
      expect(s2.border_top?).to be false
    end
  end
end
