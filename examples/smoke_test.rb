# frozen_string_literal: true

require_relative "../lib/flourish"

# Headless smoke test — exercises every feature, exits non-zero on failure.
failures = []

def assert(label, &block)
  result = block.call
  return if result

  warn "FAIL: #{label}"
  failures << label
end

# --- ANSI utilities ---
assert("ANSI.strip removes escapes") { Flourish::ANSI.strip("\e[1mhi\e[0m") == "hi" }
assert("ANSI.printable_width ignores escapes") { Flourish::ANSI.printable_width("\e[31mhi\e[0m") == 2 }
assert("ANSI.printable_width CJK") { Flourish::ANSI.printable_width("你好") == 4 }
assert("ANSI.height counts lines") { Flourish::ANSI.height("a\nb\nc") == 3 }
assert("ANSI.size returns [w, h]") { Flourish::ANSI.size("hello\nhi") == [5, 2] }

# --- Colors ---
assert("Color.parse nil") { Flourish::Color.parse(nil).no_color? }
assert("Color.parse ANSI") { Flourish::Color.parse("1").fg_sequence == "31" }
assert("Color.parse ANSI256") { Flourish::Color.parse("100").fg_sequence == "38;5;100" }
assert("Color.parse hex") { Flourish::Color.parse("#ff0000").fg_sequence == "38;2;255;0;0" }
assert("Color constants") { Flourish::Color::RED.code == 1 }

# --- Color profile ---
assert("ColorProfile constants exist") do
  [Flourish::ColorProfile::TRUE_COLOR, Flourish::ColorProfile::ANSI256,
   Flourish::ColorProfile::ANSI, Flourish::ColorProfile::NO_COLOR,].all? { |c| !c.nil? }
end

# --- Style: text attributes ---
s = Flourish::Style.new.bold.italic.foreground("#ff0")
result = s.render("hello")
assert("Style bold+italic+color") { result.include?("\e[") && result.include?("hello") }

# --- Style: padding ---
s = Flourish::Style.new.padding(1, 2)
result = s.render("hi")
lines = result.split("\n", -1)
assert("Padding adds lines") { lines.length == 3 }
assert("Padding adds spaces") { lines[1].start_with?("  ") }

# --- Style: margin ---
s = Flourish::Style.new.margin(1, 2)
result = s.render("hi")
lines = result.split("\n", -1)
assert("Margin adds empty lines") { lines[0] == "" && lines[2] == "" }

# --- Style: width ---
s = Flourish::Style.new.width(20)
result = s.render("hello")
assert("Width pads to target") { Flourish.width(result) == 20 }

# --- Style: border ---
s = Flourish::Style.new.border(Flourish::Border::ROUNDED)
result = s.render("hi")
assert("Border ROUNDED corners") { result.include?("╭") && result.include?("╯") }

s = Flourish::Style.new.border(Flourish::Border::ASCII)
result = s.render("hi")
assert("Border ASCII") { result.include?("+") && result.include?("-") && result.include?("|") }

# --- Style: border with colors ---
s = Flourish::Style.new.border(Flourish::Border::NORMAL).border_foreground("1")
result = s.render("test")
assert("Border foreground color") { result.include?("\e[31m") }

# --- Style: alignment ---
s = Flourish::Style.new.width(20).align_horizontal(0.5)
result = s.render("hi")
stripped = Flourish::ANSI.strip(result)
assert("Horizontal center alignment") { stripped.start_with?("         ") }

s = Flourish::Style.new.height(5).align_vertical(1.0)
result = s.render("hi")
lines = result.split("\n", -1)
assert("Vertical bottom alignment") { lines.last == "hi" && lines.length == 5 }

# --- Style: transform ---
s = Flourish::Style.new.transform(&:upcase)
assert("Transform") { s.render("hello") == "HELLO" }

# --- Style: tab_width ---
assert("Tab width") { Flourish::Style.new.tab_width(2).render("\t") == "  " }

# --- Style: inheritance ---
parent = Flourish::Style.new.bold.foreground("1")
child = Flourish::Style.new.italic.inherit(parent)
assert("Inheritance") { child.bold? && child.italic? }

# --- Style: copy ---
original = Flourish::Style.new.bold
copy = original.copy.italic
assert("Copy is independent") { !original.italic? && copy.bold? }

# --- Style: complex ---
s = Flourish::Style.new
                   .width(30)
                   .padding(1, 2)
                   .border(Flourish::Border::DOUBLE)
                   .border_foreground("#ff0")
                   .margin(1, 2)
                   .bold
                   .foreground("#ff0000")
                   .background("#000033")
                   .align_horizontal(0.5)
result = s.render("Flourish!")
assert("Complex render produces output") { result.length > 50 }

# --- Word wrap ---
wrapped = Flourish::Wrap.word_wrap("the quick brown fox jumps over", 10)
lines = wrapped.split("\n")
assert("Word wrap respects width") { lines.all? { |l| Flourish::ANSI.printable_width(l) <= 10 } }

# --- Borders: all presets ---
presets = [
  Flourish::Border::NORMAL, Flourish::Border::ROUNDED, Flourish::Border::THICK,
  Flourish::Border::DOUBLE, Flourish::Border::BLOCK, Flourish::Border::OUTER_HALF_BLOCK,
  Flourish::Border::INNER_HALF_BLOCK, Flourish::Border::HIDDEN,
  Flourish::Border::ASCII, Flourish::Border::MARKDOWN,
]
presets.each do |preset|
  result = Flourish::Style.new.border(preset).render("x")
  assert("Border preset #{preset.top_left}") { result.split("\n").length == 3 }
end

# --- Join horizontal ---
a = Flourish::Style.new.border(Flourish::Border::ASCII).render("A")
b = Flourish::Style.new.border(Flourish::Border::ASCII).render("B")
joined = Flourish.join_horizontal(Flourish::TOP, a, b)
assert("Join horizontal") { joined.split("\n").length == 3 }

# --- Join vertical ---
joined = Flourish.join_vertical(Flourish::LEFT, "aaa", "b")
lines = joined.split("\n")
assert("Join vertical aligns") { Flourish.width(lines[0]) == Flourish.width(lines[1]) }

# --- Place ---
placed = Flourish.place(20, 5, Flourish::CENTER, Flourish::CENTER, "hi")
lines = placed.split("\n")
assert("Place center") { lines.length == 5 && lines[2].include?("hi") }

# --- Flourish module helpers ---
assert("Flourish.width") { Flourish.width("hello") == 5 }
assert("Flourish.height") { Flourish.height("a\nb") == 2 }
assert("Flourish.size") { Flourish.size("hi\nhello") == [5, 2] }

# --- Position constants ---
assert("Position constants") do
  [Flourish::TOP, Flourish::LEFT, Flourish::CENTER, Flourish::BOTTOM, Flourish::RIGHT].all?(Numeric)
end

# --- Results ---
if failures.empty?
  puts "All smoke tests passed!"
  exit 0
else
  warn "\n#{failures.length} smoke test(s) failed"
  exit 1
end
