# frozen_string_literal: true

require "chamomile"

warn "[DEPRECATION] The `chamomile-flourish` gem is deprecated. " \
     "All styling is now part of `chamomile` (v1.0+). " \
     "Replace `require \"flourish\"` with `require \"chamomile\"` " \
     "and change `Flourish::` to `Chamomile::`."

Flourish = Chamomile unless defined?(Flourish)
