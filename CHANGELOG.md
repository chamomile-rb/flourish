# Changelog

## [Unreleased]

### Added

- Symbol position arguments: `:top`, `:left`, `:center`, `:bottom`, `:right` — accepted everywhere floats were used
- `Flourish.horizontal(boxes, align: :top)` — new primary API for horizontal layout
- `Flourish.vertical(boxes, align: :left)` — new primary API for vertical layout
- `Flourish.place(content, width:, height:, align:, valign:)` — new keyword-arg API for placement
- Block form for `horizontal` and `vertical`: `Flourish.horizontal(align: :top) { [a, b] }`

### Changed

- `Style#align_horizontal` and `Style#align_vertical` now accept symbols in addition to floats
- README updated to use symbol positions and new method names

### Deprecated

- `Flourish.join_horizontal` / `Flourish.join_vertical` — use `Flourish.horizontal` / `Flourish.vertical` instead (old methods still work)
- Float position constants (`Flourish::TOP`, `Flourish::CENTER`, etc.) — use symbols instead (constants still defined)

## [0.1.0] - 2026-02-27

### Added
- Initial release
- ANSI utilities (strip, printable_width, height, size)
- Color system (ANSI, ANSI256, TrueColor, NoColor)
- Color profile detection and downsampling
- Style class with text attributes, colors, padding, margin, borders, alignment
- Word wrap (ANSI-aware)
- 10 border presets (normal, rounded, thick, double, block, half-blocks, hidden, ASCII, markdown)
- Horizontal and vertical alignment
- Join (horizontal/vertical) and Place layout functions
