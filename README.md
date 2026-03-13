# Flourish — DEPRECATED

> **This gem is deprecated.** All styling is now part of [Chamomile](https://github.com/chamomile-rb/chamomile) v1.0+.

## Migration

1. Replace `gem "flourish"` with `gem "chamomile", "~> 1.0"` in your Gemfile
2. Replace `require "flourish"` with `require "chamomile"`
3. Replace `Flourish::` with `Chamomile::` throughout your code
4. Replace `Flourish.horizontal` / `Flourish.vertical` / `Flourish.place` with `Chamomile.horizontal` / `Chamomile.vertical` / `Chamomile.place`

All styling APIs are unchanged — just the namespace moved.

## What happened?

Chamomile v1.0 consolidated the ecosystem from three gems (chamomile, petals, flourish) into a single gem. One `gem install chamomile`, one `require "chamomile"`, one `Chamomile::` namespace.

This v0.3.0 release is a backward-compatibility shim that pulls in `chamomile` and aliases `Flourish = Chamomile`. It will print a deprecation warning on require. Use it as a bridge while you update your code.

## License

[MIT](LICENSE)
