# frozen_string_literal: true

require_relative "flourish/version"
require_relative "flourish/ansi"
require_relative "flourish/color"
require_relative "flourish/color_profile"
require_relative "flourish/wrap"
require_relative "flourish/border"
require_relative "flourish/align"
require_relative "flourish/join"
require_relative "flourish/place"
require_relative "flourish/style"

module Flourish
  # Position constants (kept for backward compat)
  TOP = 0.0
  LEFT = 0.0
  CENTER = 0.5
  BOTTOM = 1.0
  RIGHT = 1.0

  # Symbol-to-float position map
  POSITION_MAP = {
    top: 0.0,
    left: 0.0,
    center: 0.5,
    bottom: 1.0,
    right: 1.0,
  }.freeze

  class << self
    def width(str)
      ANSI.printable_width(str)
    end

    def height(str)
      ANSI.height(str)
    end

    def size(str)
      ANSI.size(str)
    end

    # New primary API — accepts array or block, keyword align
    def horizontal(strs = nil, align: :top, &block)
      strs = block.call if block && strs.nil?
      strs = Array(strs)
      Join.horizontal(resolve_position(align), *strs)
    end

    # New primary API — accepts array or block, keyword align
    def vertical(strs = nil, align: :left, &block)
      strs = block.call if block && strs.nil?
      strs = Array(strs)
      Join.vertical(resolve_position(align), *strs)
    end

    # New primary API — content first, keyword args
    # Also supports old positional form for backward compat
    def place(first, second = nil, third = nil, fourth = nil, fifth = nil,
              width: nil, height: nil, align: :left, valign: :top, content: nil)
      if fifth
        # Old 5-arg form: place(width, height, h_pos, v_pos, str)
        Place.place(first, second, resolve_position(third), resolve_position(fourth), fifth.to_s)
      else
        # New keyword form: place(content, width:, height:, align:, valign:)
        content = (content || first).to_s
        Place.place(width || 80, height || 24,
                    resolve_position(align), resolve_position(valign), content)
      end
    end

    # Old API — kept for backward compat
    def join_horizontal(position, *strs)
      Join.horizontal(resolve_position(position), *strs)
    end

    # Old API — kept for backward compat
    def join_vertical(position, *strs)
      Join.vertical(resolve_position(position), *strs)
    end

    def place_horizontal(width, pos, str)
      Place.place_horizontal(width, resolve_position(pos), str)
    end

    def place_vertical(height, pos, str)
      Place.place_vertical(height, resolve_position(pos), str)
    end

    # Convert symbol positions to float values.
    # Accepts symbols (:top, :left, :center, :bottom, :right) or floats.
    def resolve_position(val)
      case val
      when Symbol
        POSITION_MAP.fetch(val) { raise ArgumentError, "Unknown position: #{val.inspect}" }
      when Numeric
        val.to_f
      else
        raise ArgumentError, "Expected a Symbol or Numeric position, got #{val.inspect}"
      end
    end
  end
end
