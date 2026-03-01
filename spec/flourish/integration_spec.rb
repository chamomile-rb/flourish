# frozen_string_literal: true

RSpec.describe "Flourish integration" do
  describe "module-level helpers" do
    it "Flourish.width delegates to ANSI.printable_width" do
      expect(Flourish.width("hello")).to eq(5)
    end

    it "Flourish.height delegates to ANSI.height" do
      expect(Flourish.height("a\nb")).to eq(2)
    end

    it "Flourish.size delegates to ANSI.size" do
      expect(Flourish.size("hi\nhello")).to eq([5, 2])
    end

    it "Flourish.width handles ANSI codes" do
      expect(Flourish.width("\e[1mhi\e[0m")).to eq(2)
    end
  end

  describe "position constants" do
    it "defines TOP as 0.0" do
      expect(Flourish::TOP).to eq(0.0)
    end

    it "defines LEFT as 0.0" do
      expect(Flourish::LEFT).to eq(0.0)
    end

    it "defines CENTER as 0.5" do
      expect(Flourish::CENTER).to eq(0.5)
    end

    it "defines BOTTOM as 1.0" do
      expect(Flourish::BOTTOM).to eq(1.0)
    end

    it "defines RIGHT as 1.0" do
      expect(Flourish::RIGHT).to eq(1.0)
    end
  end

  describe "Flourish.join_horizontal" do
    it "delegates to Join.horizontal" do
      result = Flourish.join_horizontal(Flourish::TOP, "a", "b")
      expect(result).to eq("ab")
    end
  end

  describe "Flourish.join_vertical" do
    it "delegates to Join.vertical" do
      result = Flourish.join_vertical(Flourish::LEFT, "a", "b")
      expect(result).to eq("a\nb")
    end
  end

  describe "Flourish.place" do
    it "delegates to Place.place" do
      result = Flourish.place(10, 3, Flourish::CENTER, Flourish::CENTER, "hi")
      lines = result.split("\n")
      expect(lines.length).to eq(3)
    end
  end

  describe "Flourish.place_horizontal" do
    it "delegates to Place.place_horizontal" do
      result = Flourish.place_horizontal(10, Flourish::RIGHT, "hi")
      expect(result).to end_with("hi")
    end
  end

  describe "Flourish.place_vertical" do
    it "delegates to Place.place_vertical" do
      result = Flourish.place_vertical(5, Flourish::CENTER, "hi")
      lines = result.split("\n", -1)
      expect(lines.length).to eq(5)
    end
  end

  describe "composing styles with join" do
    it "joins two bordered boxes horizontally" do
      a = Flourish::Style.new.border(Flourish::Border::ASCII).render("A")
      b = Flourish::Style.new.border(Flourish::Border::ASCII).render("B")
      result = Flourish.join_horizontal(Flourish::TOP, a, b)
      lines = result.split("\n")
      expect(lines.length).to eq(3)
    end

    it "joins two bordered boxes vertically" do
      a = Flourish::Style.new.border(Flourish::Border::ASCII).render("A")
      b = Flourish::Style.new.border(Flourish::Border::ASCII).render("B")
      result = Flourish.join_vertical(Flourish::LEFT, a, b)
      lines = result.split("\n")
      expect(lines.length).to eq(6)
    end

    it "places a styled box in a larger area" do
      box = Flourish::Style.new
                           .bold
                           .foreground("#ff0")
                           .border(Flourish::Border::ROUNDED)
                           .render("centered")
      result = Flourish.place(40, 10, Flourish::CENTER, Flourish::CENTER, box)
      lines = result.split("\n")
      expect(lines.length).to eq(10)
      lines.each { |l| expect(Flourish.width(l)).to eq(40) }
    end
  end

  describe "style with all features" do
    it "renders a fully featured style" do
      result = Flourish::Style.new
                              .bold
                              .italic
                              .foreground("#ff0000")
                              .background("#000033")
                              .width(30)
                              .padding(1, 2)
                              .border(Flourish::Border::DOUBLE)
                              .border_foreground("#ff0")
                              .margin(1)
                              .align_horizontal(0.5)
                              .render("Hello!")

      lines = result.split("\n", -1)
      expect(lines.length).to be >= 7
      expect(result).to include("Hello!")
    end
  end

  describe "color profile downsampling with style" do
    it "downsample TrueColor to ANSI256" do
      color = Flourish::Color.parse("#ff0000")
      result = Flourish::ColorProfile.downsample(color, Flourish::ColorProfile::ANSI256)
      expect(result).to be_a(Flourish::Color::ANSI256Color)
      expect(result.fg_sequence).to start_with("38;5;")
    end

    it "downsample TrueColor to ANSI" do
      color = Flourish::Color.parse("#ff0000")
      result = Flourish::ColorProfile.downsample(color, Flourish::ColorProfile::ANSI)
      expect(result).to be_a(Flourish::Color::ANSIColor)
    end
  end
end
