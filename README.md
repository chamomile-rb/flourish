# Flourish

Terminal styling library for Ruby. CSS-like box model with colors, borders, padding, alignment, and layout composition.

Part of the [Chamomile](https://github.com/chamomile-rb/chamomile) ecosystem. Zero runtime dependencies.

## Installation

```ruby
# Gemfile
gem "flourish"
```

## Quick Start

```ruby
require "flourish"

style = Flourish::Style.new
  .bold
  .foreground("#7d56f4")
  .padding(1, 2)
  .border(Flourish::Border::ROUNDED)
  .border_foreground("#7d56f4")

puts style.render("Hello, World!")
```

## Features

### Text Attributes

```ruby
Flourish::Style.new.bold.render("bold")
Flourish::Style.new.italic.render("italic")
Flourish::Style.new.faint.render("faint")
Flourish::Style.new.underline.render("underline")
Flourish::Style.new.strikethrough.render("strikethrough")
Flourish::Style.new.reverse.render("reverse video")
Flourish::Style.new.blink.render("blink")
```

### Colors

```ruby
# True color (hex)
Flourish::Style.new.foreground("#ff0000").render("red")
Flourish::Style.new.background("#0000ff").render("blue bg")

# ANSI 256
Flourish::Style.new.foreground("196").render("ansi256 red")

# Basic ANSI (0-15)
Flourish::Style.new.foreground("1").render("ansi red")
```

### Borders

10 built-in presets: `NORMAL`, `ROUNDED`, `THICK`, `DOUBLE`, `BLOCK`, `OUTER_HALF_BLOCK`, `INNER_HALF_BLOCK`, `HIDDEN`, `ASCII`, `MARKDOWN`

```ruby
Flourish::Style.new
  .border(Flourish::Border::ROUNDED)
  .border_foreground("#7d56f4")
  .padding(0, 1)
  .render("rounded box")

# Per-side border control
Flourish::Style.new
  .border(Flourish::Border::NORMAL, true, false, true, false)  # top, right, bottom, left
  .render("horizontal lines only")

# Per-side colors (top, right, bottom, left)
Flourish::Style.new
  .border(Flourish::Border::ROUNDED)
  .border_foreground("#ff0000", "#00ff00", "#0000ff", "#ffff00")
  .render("rainbow border")
```

### Dimensions & Spacing

```ruby
# Fixed dimensions
Flourish::Style.new.width(40).height(10).render("fixed box")

# Max constraints
Flourish::Style.new.max_width(60).render(long_text)

# Padding and margin (CSS shorthand: 1, 2, 3, or 4 args)
Flourish::Style.new.padding(1, 2).margin(0, 1).render("spaced")
```

### Alignment

```ruby
Flourish::Style.new.width(40).align_horizontal(:center).render("centered")
Flourish::Style.new.height(10).align_vertical(:center).render("vertically centered")

# Position symbols: :left/:top, :center, :right/:bottom
```

### Layout Composition

```ruby
# Side by side
Flourish.horizontal([box_a, box_b, box_c], align: :top)

# Stacked
Flourish.vertical([header, body, footer], align: :left)

# Block form
Flourish.horizontal(align: :top) { [box_a, box_b, box_c] }

# Place content in a fixed-size box
Flourish.place(content, width: 80, height: 24, align: :center, valign: :center)
```

### Style Inheritance & Copy

```ruby
base = Flourish::Style.new.bold.foreground("#fff")
derived = base.copy.background("#333")  # independent copy
other = Flourish::Style.new.inherit(base)  # inherit unset props
```

### ANSI Utilities

```ruby
Flourish::ANSI.strip("\e[1mhello\e[0m")      # "hello"
Flourish::ANSI.printable_width("hello")        # 5 (CJK-aware)
Flourish::ANSI.height("line1\nline2\nline3")   # 3
```

### Color Profile Detection

```ruby
profile = Flourish::ColorProfile.detect  # auto-detect terminal capabilities
color = profile.color("#ff0000")          # downsamples if needed (TrueColor -> 256 -> 16)
```

## Examples

```sh
ruby examples/kitchen_sink.rb            # comprehensive feature showcase (21 features)
ruby examples/layout_demo.rb             # styled box composition
ruby examples/layout_demo_interactive.rb # multi-panel UI (requires chamomile + petals)
ruby examples/smoke_test.rb              # headless test of all features
```

## Ecosystem

| Gem | Description |
|-----|-------------|
| **[chamomile](https://github.com/chamomile-rb/chamomile)** | Core TUI framework (event-driven event loop) |
| **[petals](https://github.com/chamomile-rb/petals)** | Reusable TUI components — Spinner, TextInput, Viewport, Table, List, and more |
| **flourish** | Terminal styling (this gem) |

## Development

```sh
bundle install
bundle exec rspec        # run tests
bundle exec rubocop      # lint
```

## License

[MIT](LICENSE)
