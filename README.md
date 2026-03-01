# Flourish

Terminal styling library for Ruby. CSS-like box model with colors, borders, padding, alignment, and layout composition. Inspired by Go's [Lip Gloss](https://github.com/charmbracelet/lipgloss).

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
Flourish::Style.new.width(40).align_horizontal(Flourish::CENTER).render("centered")
Flourish::Style.new.height(10).align_vertical(Flourish::CENTER).render("vertically centered")

# Position constants: LEFT/TOP = 0.0, CENTER = 0.5, RIGHT/BOTTOM = 1.0
```

### Layout Composition

```ruby
# Side by side
Flourish.join_horizontal(Flourish::TOP, box_a, box_b, box_c)

# Stacked
Flourish.join_vertical(Flourish::LEFT, header, body, footer)

# Place content in a fixed-size box
Flourish.place(80, 24, Flourish::CENTER, Flourish::CENTER, content)
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
ruby examples/layout_demo_interactive.rb # lazygit-style multi-panel UI (requires chamomile + petals)
ruby examples/smoke_test.rb              # headless test of all features
```

### Interactive Layout Demo

The `layout_demo_interactive.rb` example combines all three gems to create a Lazygit-style multi-panel interface:

- 5 stacked left panels + 1 large detail panel
- Tab/Shift+Tab to cycle focus between panels
- j/k to scroll within panels
- Context-sensitive detail pane with fake diffs
- Terminal resize support

## Ecosystem

| Gem | Description |
|-----|-------------|
| **[chamomile](https://github.com/chamomile-rb/chamomile)** | Core TUI framework (Elm Architecture event loop) |
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
