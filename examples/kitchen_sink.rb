# frozen_string_literal: true

require_relative "../lib/flourish"

# Kitchen Sink — showcases every Flourish feature in a visual terminal demo.

# ─── Section Header Helper ──────────────────────────────────────────
def section(title)
  style = Flourish::Style.new
                         .bold
                         .foreground("#fafafa")
                         .background("#7d56f4")
                         .padding(0, 2)
                         .width(72)
                         .align_horizontal(Flourish::CENTER)
  puts "\n#{style.render(title)}\n"
end

# ═══════════════════════════════════════════════════════════════════════
#  1. TEXT ATTRIBUTES
# ═══════════════════════════════════════════════════════════════════════
section("1. Text Attributes")

attrs = {
  "Bold" => Flourish::Style.new.bold,
  "Italic" => Flourish::Style.new.italic,
  "Faint" => Flourish::Style.new.faint,
  "Underline" => Flourish::Style.new.underline,
  "Strikethrough" => Flourish::Style.new.strikethrough,
  "Blink" => Flourish::Style.new.blink,
  "Reverse" => Flourish::Style.new.reverse,
  "All Combined" => Flourish::Style.new.bold.italic.underline.faint,
}

attrs.each do |name, style|
  puts "  #{style.render(name)}"
end

# ═══════════════════════════════════════════════════════════════════════
#  2. COLORS — ANSI, ANSI256, True Color
# ═══════════════════════════════════════════════════════════════════════
section("2. Colors")

puts "  ANSI (0-15):"
row = (0..15).map do |code|
  Flourish::Style.new.background(code.to_s).render("   ")
end
puts "  #{row.join}"

puts "\n  ANSI 256 (grayscale ramp 232-255):"
row = (232..255).map do |code|
  Flourish::Style.new.background(code.to_s).render("  ")
end
puts "  #{row.join}"

puts "\n  True Color gradient:"
row = (0..71).map do |i|
  r = (255 * Math.sin(0.09 * i)).abs.to_i.clamp(0, 255)
  g = (255 * Math.sin((0.09 * i) + 2)).abs.to_i.clamp(0, 255)
  b = (255 * Math.sin((0.09 * i) + 4)).abs.to_i.clamp(0, 255)
  hex = format("#%02x%02x%02x", r, g, b)
  Flourish::Style.new.background(hex).render(" ")
end
puts "  #{row.join}"

puts "\n  Foreground colors:"
colors = { "Red" => "#ff0000", "Green" => "#00ff00", "Blue" => "#0000ff",
           "Yellow" => "#ffff00", "Magenta" => "#ff00ff", "Cyan" => "#00ffff", }
line = colors.map { |name, hex| Flourish::Style.new.foreground(hex).bold.render(name) }
puts "  #{line.join("  ")}"

# ═══════════════════════════════════════════════════════════════════════
#  3. COLOR PROFILE DOWNSAMPLING
# ═══════════════════════════════════════════════════════════════════════
section("3. Color Profile Downsampling")

original = Flourish::Color.parse("#ff6347")
puts "  Original: #ff6347 → fg_sequence: #{original.fg_sequence}"

ansi256 = Flourish::ColorProfile.downsample(original, Flourish::ColorProfile::ANSI256)
puts "  → ANSI256:  code #{ansi256.code}, fg_sequence: #{ansi256.fg_sequence}"

ansi = Flourish::ColorProfile.downsample(original, Flourish::ColorProfile::ANSI)
puts "  → ANSI:     code #{ansi.code}, fg_sequence: #{ansi.fg_sequence}"

no_color = Flourish::ColorProfile.downsample(original, Flourish::ColorProfile::NO_COLOR)
puts "  → NO_COLOR: #{no_color.class.name.split("::").last} (no_color? = #{no_color.no_color?})"

puts "\n  Current profile: #{Flourish::ColorProfile.detect}"

# ═══════════════════════════════════════════════════════════════════════
#  4. PADDING
# ═══════════════════════════════════════════════════════════════════════
section("4. Padding")

padded = Flourish::Style.new
                        .padding(1, 4)
                        .background("#333333")
                        .foreground("#ffffff")
                        .render("Padding: 1 vertical, 4 horizontal")
puts padded

padded_asym = Flourish::Style.new
                             .padding(0, 2, 1, 6)
                             .background("#2d2d2d")
                             .foreground("#aaaaaa")
                             .render("Asymmetric: top=0 right=2 bottom=1 left=6")
puts padded_asym

# ═══════════════════════════════════════════════════════════════════════
#  5. MARGIN
# ═══════════════════════════════════════════════════════════════════════
section("5. Margin")

margined = Flourish::Style.new
                          .margin(1, 4)
                          .background("#444444")
                          .foreground("#ffffff")
                          .padding(0, 1)
                          .render("Margin: 1 vertical, 4 horizontal")
puts margined

# ═══════════════════════════════════════════════════════════════════════
#  6. WIDTH & HEIGHT
# ═══════════════════════════════════════════════════════════════════════
section("6. Width & Height")

fixed = Flourish::Style.new
                       .width(40)
                       .height(3)
                       .background("#1a1a2e")
                       .foreground("#e94560")
                       .padding(0, 1)
                       .render("Fixed 40x3 box")
puts fixed

puts "\n  Max width truncation:"
truncated = Flourish::Style.new
                           .max_width(30)
                           .foreground("#ff9900")
                           .bold
                           .render("This long sentence will be truncated at 30 visible characters")
puts "  #{truncated}"

# ═══════════════════════════════════════════════════════════════════════
#  7. WORD WRAP
# ═══════════════════════════════════════════════════════════════════════
section("7. Word Wrap")

long_text = "Flourish brings CSS-like styling to the terminal. " \
            "It handles padding, margin, borders, alignment, " \
            "and colors with automatic profile downsampling."

wrapped = Flourish::Style.new
                         .width(40)
                         .padding(1, 2)
                         .background("#1e1e2e")
                         .foreground("#cdd6f4")
                         .render(long_text)
puts wrapped

# ═══════════════════════════════════════════════════════════════════════
#  8. BORDERS — All 10 Presets
# ═══════════════════════════════════════════════════════════════════════
section("8. Border Presets")

border_presets = [
  ["NORMAL",           Flourish::Border::NORMAL],
  ["ROUNDED",          Flourish::Border::ROUNDED],
  ["THICK",            Flourish::Border::THICK],
  ["DOUBLE",           Flourish::Border::DOUBLE],
  ["BLOCK",            Flourish::Border::BLOCK],
  ["OUTER_HALF_BLOCK", Flourish::Border::OUTER_HALF_BLOCK],
  ["INNER_HALF_BLOCK", Flourish::Border::INNER_HALF_BLOCK],
  ["HIDDEN",           Flourish::Border::HIDDEN],
  ["ASCII",            Flourish::Border::ASCII],
  ["MARKDOWN",         Flourish::Border::MARKDOWN],
]

# Render in rows of 5
border_presets.each_slice(5) do |group|
  boxes = group.map do |name, preset|
    Flourish::Style.new
                   .border(preset)
                   .width(14)
                   .align_horizontal(Flourish::CENTER)
                   .render(name)
  end
  puts Flourish.join_horizontal(Flourish::TOP, *boxes)
end

# ═══════════════════════════════════════════════════════════════════════
#  9. BORDER COLORS — Per-Side Foreground
# ═══════════════════════════════════════════════════════════════════════
section("9. Border Colors")

colored_border = Flourish::Style.new
                                .border(Flourish::Border::ROUNDED)
                                .border_foreground("#ff0000", "#00ff00", "#0000ff", "#ffff00")
                                .padding(1, 2)
                                .width(40)
                                .align_horizontal(Flourish::CENTER)
                                .render("4 border colors!\nTop=Red Right=Green\nBottom=Blue Left=Yellow")
puts colored_border

border_bg = Flourish::Style.new
                           .border(Flourish::Border::NORMAL)
                           .border_foreground("#ffffff")
                           .border_background("#7d56f4")
                           .padding(0, 2)
                           .render("Border with background color")
puts border_bg

# ═══════════════════════════════════════════════════════════════════════
#  10. SELECTIVE BORDERS
# ═══════════════════════════════════════════════════════════════════════
section("10. Selective Borders")

top_bottom = Flourish::Style.new
                            .border(Flourish::Border::NORMAL, true, false, true, false)
                            .border_foreground("#ff7698")
                            .width(30)
                            .align_horizontal(Flourish::CENTER)
                            .render("Top & Bottom only")

left_only = Flourish::Style.new
                           .border(Flourish::Border::THICK)
                           .border_top(false)
                           .border_right(false)
                           .border_bottom(false)
                           .border_foreground("#04b575")
                           .render("Left border only")

puts Flourish.join_horizontal(Flourish::TOP, top_bottom, "  ", left_only)

# ═══════════════════════════════════════════════════════════════════════
#  11. ALIGNMENT
# ═══════════════════════════════════════════════════════════════════════
section("11. Alignment")

align_box = Flourish::Style.new
                           .width(30)
                           .height(3)
                           .border(Flourish::Border::ROUNDED)
                           .border_foreground("#888888")

left = align_box.copy
                .align_horizontal(Flourish::LEFT)
                .render("Left")

center = align_box.copy
                  .align_horizontal(Flourish::CENTER)
                  .render("Center")

right = align_box.copy
                 .align_horizontal(Flourish::RIGHT)
                 .render("Right")

puts Flourish.join_horizontal(Flourish::TOP, left, center, right)

puts ""

vtop = Flourish::Style.new
                      .width(20)
                      .height(7)
                      .border(Flourish::Border::ROUNDED)
                      .border_foreground("#888888")
                      .align_vertical(Flourish::TOP)
                      .align_horizontal(Flourish::CENTER)
                      .render("Top")

vcenter = Flourish::Style.new
                         .width(20)
                         .height(7)
                         .border(Flourish::Border::ROUNDED)
                         .border_foreground("#888888")
                         .align_vertical(Flourish::CENTER)
                         .align_horizontal(Flourish::CENTER)
                         .render("Center")

vbot = Flourish::Style.new
                      .width(20)
                      .height(7)
                      .border(Flourish::Border::ROUNDED)
                      .border_foreground("#888888")
                      .align_vertical(Flourish::BOTTOM)
                      .align_horizontal(Flourish::CENTER)
                      .render("Bottom")

puts Flourish.join_horizontal(Flourish::TOP, vtop, vcenter, vbot)

# ═══════════════════════════════════════════════════════════════════════
#  12. TRANSFORM
# ═══════════════════════════════════════════════════════════════════════
section("12. Transform")

upper = Flourish::Style.new
                       .transform(&:upcase)
                       .bold
                       .foreground("#ff6347")
                       .render("this text was lowercased")
puts "  #{upper}"

reversed = Flourish::Style.new
                          .transform(&:reverse)
                          .italic
                          .foreground("#4ecdc4")
                          .render("!sdrawkcab si txet sihT")
puts "  #{reversed}"

# ═══════════════════════════════════════════════════════════════════════
#  13. INHERITANCE & COPY
# ═══════════════════════════════════════════════════════════════════════
section("13. Inheritance & Copy")

base = Flourish::Style.new
                      .bold
                      .foreground("#fafafa")
                      .background("#333333")
                      .padding(0, 2)

child1 = Flourish::Style.new
                        .italic
                        .foreground("#ff7698")
                        .inherit(base)
child1_out = child1.render("Inherits bold+bg, overrides fg")

child2 = base.copy.foreground("#04b575")
child2_out = child2.render("Copied base, changed fg to green")

puts child1_out
puts child2_out

# ═══════════════════════════════════════════════════════════════════════
#  14. TAB WIDTH
# ═══════════════════════════════════════════════════════════════════════
section("14. Tab Width")

tab2 = Flourish::Style.new
                      .tab_width(2)
                      .border(Flourish::Border::ROUNDED)
                      .border_foreground("#666666")
                      .render("tab=2:\n\tindented\n\t\tdouble")

tab4 = Flourish::Style.new
                      .tab_width(4)
                      .border(Flourish::Border::ROUNDED)
                      .border_foreground("#666666")
                      .render("tab=4:\n\tindented\n\t\tdouble")

tab8 = Flourish::Style.new
                      .tab_width(8)
                      .border(Flourish::Border::ROUNDED)
                      .border_foreground("#666666")
                      .render("tab=8:\n\tindented\n\t\tdouble")

puts Flourish.join_horizontal(Flourish::TOP, tab2, " ", tab4, " ", tab8)

# ═══════════════════════════════════════════════════════════════════════
#  15. WHITESPACE OPTIONS
# ═══════════════════════════════════════════════════════════════════════
section("15. Whitespace Options")

colored_ws = Flourish::Style.new
                            .padding(1, 3)
                            .background("#2d1b69")
                            .foreground("#ffffff")
                            .color_whitespace(true)
                            .render("color_whitespace: true\nBackground fills padding")
puts colored_ws

ul_spaces = Flourish::Style.new
                           .underline
                           .underline_spaces(true)
                           .width(40)
                           .render("underline_spaces: true")
puts "  #{ul_spaces}"

st_spaces = Flourish::Style.new
                           .strikethrough
                           .strikethrough_spaces(true)
                           .width(40)
                           .render("strikethrough_spaces: true")
puts "  #{st_spaces}"

# ═══════════════════════════════════════════════════════════════════════
#  16. JOIN HORIZONTAL
# ═══════════════════════════════════════════════════════════════════════
section("16. Join Horizontal")

box_style = Flourish::Style.new
                           .border(Flourish::Border::ROUNDED)
                           .padding(1, 2)
                           .width(22)

box_a = box_style.copy
                 .border_foreground("#ff6347")
                 .foreground("#ff6347")
                 .render("Box A\nTomato")

box_b = box_style.copy
                 .border_foreground("#4ecdc4")
                 .foreground("#4ecdc4")
                 .render("Box B\nTeal")

box_c = box_style.copy
                 .border_foreground("#ffe66d")
                 .foreground("#ffe66d")
                 .render("Box C\nYellow")

puts "  Top-aligned:"
puts Flourish.join_horizontal(Flourish::TOP, box_a, box_b, box_c)

# ═══════════════════════════════════════════════════════════════════════
#  17. JOIN VERTICAL
# ═══════════════════════════════════════════════════════════════════════
section("17. Join Vertical")

header = Flourish::Style.new
                        .bold
                        .foreground("#fafafa")
                        .background("#7d56f4")
                        .width(50)
                        .padding(0, 2)
                        .align_horizontal(Flourish::CENTER)
                        .render("Header")

body = Flourish::Style.new
                      .border(Flourish::Border::ROUNDED)
                      .border_foreground("#874bfa")
                      .width(50)
                      .padding(1, 2)
                      .render("Body content goes here.\nMultiple lines supported.")

footer = Flourish::Style.new
                        .foreground("#666666")
                        .italic
                        .width(50)
                        .align_horizontal(Flourish::RIGHT)
                        .render("Footer — right aligned")

puts Flourish.join_vertical(Flourish::CENTER, header, body, footer)

# ═══════════════════════════════════════════════════════════════════════
#  18. PLACE
# ═══════════════════════════════════════════════════════════════════════
section("18. Place")

placed = Flourish.place(40, 5, Flourish::CENTER, Flourish::CENTER, "Centered in 40x5")
puts Flourish::Style.new
                    .border(Flourish::Border::ROUNDED)
                    .border_foreground("#555555")
                    .render(placed)

h_placed = Flourish.place_horizontal(50, Flourish::RIGHT, "Right-placed text")
puts Flourish::Style.new
                    .border(Flourish::Border::HIDDEN)
                    .render(h_placed)

# ═══════════════════════════════════════════════════════════════════════
#  19. CJK & WIDE CHARACTER SUPPORT
# ═══════════════════════════════════════════════════════════════════════
section("19. CJK & Wide Characters")

cjk_box = Flourish::Style.new
                         .border(Flourish::Border::DOUBLE)
                         .border_foreground("#ff6347")
                         .padding(0, 1)
                         .render("你好世界 — Hello World")

puts cjk_box
puts "  Width: #{Flourish.width("你好世界")} cells (4 chars, 8 cells)"

# ═══════════════════════════════════════════════════════════════════════
#  20. COMPLEX COMPOSITION
# ═══════════════════════════════════════════════════════════════════════
section("20. Complex Composition")

# Sidebar
sidebar = Flourish::Style.new
                         .border(Flourish::Border::ROUNDED)
                         .border_foreground("#874bfa")
                         .foreground("#cdd6f4")
                         .width(20)
                         .height(10)
                         .padding(1, 1)
                         .render("Navigation\n\n> Home\n  About\n  Contact\n  Settings")

# Main content
main = Flourish::Style.new
                      .border(Flourish::Border::ROUNDED)
                      .border_foreground("#04b575")
                      .foreground("#cdd6f4")
                      .width(50)
                      .height(10)
                      .padding(1, 2)
                      .render("Welcome to Flourish!\n\n" \
                              "A terminal styling library for Ruby,\n" \
                              "inspired by charmbracelet/lipgloss.\n\n" \
                              "CSS-like box model for your TUI.")

# Title bar
title_bar = Flourish::Style.new
                           .bold
                           .foreground("#fafafa")
                           .background("#7d56f4")
                           .width(72)
                           .padding(0, 2)
                           .align_horizontal(Flourish::CENTER)
                           .render("Flourish Kitchen Sink")

# Status bar
status_bar = Flourish::Style.new
                            .foreground("#fafafa")
                            .background("#333333")
                            .width(72)
                            .padding(0, 2)
                            .render(
                              "v#{Flourish::VERSION}  |  #{Flourish::ColorProfile.detect}  |  Ruby #{RUBY_VERSION}"
                            )

# Compose the layout
content = Flourish.join_horizontal(Flourish::TOP, sidebar, " ", main)
layout = Flourish.join_vertical(Flourish::LEFT, title_bar, content, status_bar)

puts layout

# ═══════════════════════════════════════════════════════════════════════
#  21. ANSI UTILITIES
# ═══════════════════════════════════════════════════════════════════════
section("21. ANSI Utilities")

styled = "\e[1;31mBold Red\e[0m normal \e[4;34mUnderline Blue\e[0m"
puts "  Styled:  #{styled}"
puts "  Stripped: #{Flourish::ANSI.strip(styled)}"
puts "  Width:    #{Flourish::ANSI.printable_width(styled)} visible cells"
puts "  Height:   #{Flourish::ANSI.height("line1\nline2\nline3")} lines"
puts "  Size:     #{Flourish::ANSI.size("hello\nworld!").inspect} [w, h]"

# ═══════════════════════════════════════════════════════════════════════
#  DONE
# ═══════════════════════════════════════════════════════════════════════
puts ""
done = Flourish::Style.new
                      .bold
                      .foreground("#04b575")
                      .background("#1a1a2e")
                      .padding(1, 4)
                      .border(Flourish::Border::DOUBLE)
                      .border_foreground("#04b575")
                      .width(72)
                      .align_horizontal(Flourish::CENTER)
                      .render("Kitchen Sink Complete! All 21 features showcased.")
puts done
