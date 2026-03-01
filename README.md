# Flourish

Terminal styling library for Ruby. CSS-like box model for terminal output.

Part of the [Chamomile](https://github.com/xjackk/chamomile) ecosystem.

## Installation

```ruby
gem "flourish"
```

## Usage

```ruby
require "flourish"

style = Flourish::Style.new
  .bold(true)
  .foreground("#ff0")
  .padding(1, 2)
  .border(Flourish::Border::ROUNDED)

puts style.render("Hello, World!")
```

## License

MIT
